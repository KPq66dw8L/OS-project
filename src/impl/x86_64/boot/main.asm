; Virtual memory concept: -------------------------------------------
; All data in memory is stored at different addresses, however rather
; than working with physical addresses in RAM (slower?), we tipically
; work with virtual addresses. Then mapped to physical addresses by
; the CPU, page by page. So the CPU sees virtual addresses.
; Virtual   Physical       Data
; 1 ------> 0xfed50000 --> H
; 2 ------> 0xfed60000 --> E
; 3 ------> 0xfed70000 --> L
; 4 ------> 0xfed80000 --> L
; 5 ------> 0xfed90000 --> O
; Benefits: https://youtu.be/wz9CZBeXR6U?t=472

; Page : 4KB (4096 bytes) of memory ---------------------------------
; Pages: ------------------------------------------------------------
; There is 4 types a page table: Level 4, Level 3, Level 2, Level 1.
; Each table is a 4KB block of memory and can contain 512 entries.
; Each virtual address takes up 48 bits of the 64 available bits.
; The other bits are unused. 
; The CPU treats the first 9 bits of the virtual address as an index
; into the Level 4 page table. The corresponding entry in the Level 4
; table is a pointer/index to the Level 3 page table. The CPU then 
; uses the next 9 bits as an index into the Level 3 page table. etc.
; Until the Level 1 page table is reached. In L1 the index corresponds
; to a physical address.
; The final bits are used as an offset into the physical page.
; The final bit is used to indicate if the page is present or not.
; ---> The CPU determines the address of the L4 page table by reading
; the CR3 register.
; See: https://youtu.be/wz9CZBeXR6U?t=571

global start ; To access start when we are linking
extern long_mode_start

section .text
bits 32 ; puisque l'on est encore en 32bits mode (in Part 1)
start:
    ; Stack impl related:
    mov esp, stack_top ; esp = stack pointer (pointing to the top frame of the stack)
    ; End `Stack impl related`

    ; Switch to 64bits mode related:
    ; Long-mode checks related:
    call check_multiboot ; Check that we have been loaded by a Multiboot-compliant bootloader
    call check_cpuid ; cpuid is a function that is available on all x86 processors, providing various infos about the CPU
    call check_long_mode ; We need to put the CPU in `long mode` to get in 64bits
    
    ; We need virtual memory to enter 64bit mode through a process called Paging.
    ; We do this by creating Page Tables (PTs)
    call setup_page_tables
    call enable_paging
    ; We are not in 64 bits mode yet, we are in a 32 bits compatibility  
    ; submode.
    ; We need a global descriptor table
    lgdt [gdt64.pointer] ; Load the global descriptor table

    ; To finish, we need to load our code segment into the code 
    ; selector (CS) register in the CPU.
    jmp gdt64.code_segment:long_mode_start ; The CPU will jmp to 64 code


    ; End `Switch to 64bits mode related`

    ; --------------- Part 1 ---------------
    ; print `OK`
    ; mov dword [0xb8000], 0x2f4b2f4f ; we write directly to `video memory`, `OK`
    hlt
    ; next -> go to /targets/linker.ld (for linking)
    ; --------------- End Part 1 ---------------

; In asm: subroutine = function (e.g `check_multiboot`)
check_multiboot:
    cmp eax, 0x36d76289 ; Check that the magic number is correct, number stored in eax by the bootloader
    jne .no_multiboot ; If not, jump to `no_multiboot` (jne: https://stackoverflow.com/questions/14267081/difference-between-je-jne-and-jz-jnz)
    ret ; If the magic number is correct, return to the next instruction
.no_multiboot: ; Label: https://docs.oracle.com/cd/E19120-01/open.solaris/817-5477/esqaq/index.html
    mov al, "M" ; If the magic number is not correct, we write `M` in the al reg
    jmp error

check_cpuid: ; We need to flip the `id` bit of the flags register. If we can flip it, then CPUID is available
    pushfd ; Push the original flags register on the stack
    pop eax ; Pop the original flags register into the eax reg
    mov ecx, eax ; Make a copy of it in ecx, to compare later on
    xor eax, 1 << 21 ; Flip the `id` bit (bit 21) of the original flags register
    push eax ; Push the modified flags register on the stack
    popfd ; Pop the modified flags register into the flags register
    pushfd ; Push the flags register on the stack
    pop eax ; Pop the flags register into the eax reg
    ; If the `id` bit of the flags register is flipped, CPUID is available and the CPU didn't reverse it
    push ecx ; Push the original flags register on the stack
    popfd ; Pop the original flags register into the flags register
    cmp eax, ecx ; Compare the original flags register with the modified one
    ; If they match, the CPU didn't allow cpuid
    je .no_cpuid ; If they match, jump to `no_cpuid`
    ret
.no_cpuid: 
    mov al, "C" ; If CPUID is not available, we write `C` in the al reg
    jmp error

; Since cpuid has been extended over time, we need to check if cpuid
; supports extended processor infos.
check_long_mode:
    mov eax, 0x80000000 
    cpuid ; This takes the eax register as an implicit arg and puts the result in eax
    cmp eax, 0x80000001 ; If eax now contains a number greater than 0x80000000
    jb .no_long_mode ; If eax is less than 0x80000001, jump to `no_long_mode`
    ; jb: https://stackoverflow.com/questions/53451732/js-and-jb-instructions-in-assembly

    mov eax, 0x80000001 ; We will use the extended CPU infos to check if long mode is available
    cpuid ; This time, cpuid will store a value in edx reg
    ; If the lm bit (bit 29) is set in edx, long mode is available
    test edx, 1 << 29 ; If the lm bit is set in edx
    jz .no_long_mode 

    ret
.no_long_mode:
    mov al, "L" ; If long mode is not available, we write `L` in the al reg
    jmp error

setup_page_tables:
    ; We will be doing `identity mapping` = `one-to-one mapping`.
    ; The physical address corresponds to the virtual address with 
    ; the same address. https://youtu.be/wz9CZBeXR6U?t=621
    mov eax, page_table_l3
    or eax, 0b11 ; Set the `P` bit(present) and the `RW` bit(writable)
    mov [page_table_l4], eax ; Store the value in the L4 page table

    mov eax, page_table_l2
    or eax, 0b11 
    mov [page_table_l3], eax 
    ; We will enable `huge page flag` on any entry in the l2 table
    ; With that we can point directly into the physical memory and
    ; allocate a huge page of 2MB. This just reduces the work here.

    ; So we will fill up the 512 entries of the l2 table. Each entry
    ; of 2MB for a total of 1GB that we will identity map to the 
    ; physical memory.
    mov ecx, 0 ; counter (of a for loop)
.loop:

    mov eax, 0x200000 ; 2MB
    mul ecx ; eax = eax * ecx -> the have the correct address for the next page
    or eax, 0b10000011 ; Set the present bit, writable bit and the huge page flag bit
    mov [page_table_l2 + ecx * 8], eax ; Store the value in the L2 page table
    
    ; End of the loop
    inc ecx ; increment counter
    cmp ecx, 512 ; checks if the whole table is mapped 
    jne .loop ; if not, continue

    ret

enable_paging:
    ; pass page table location to the CPU
    mov eax, page_table_l4
    mov cr3, eax

    ; enable physical address extension PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; enable long mode
    mov ecx, 0xC0000080 ; magic value
    rdmsr ; Read model specific register = load value of efer reg into eax
    or eax, 1 << 8 ; Set the `LME` bit (bit 8) of the efer reg
    wrmsr ; Write back into the model specific register 

    ; enable paging
    mov eax, cr0
    or eax, 1 << 31 ; Set the `PG` bit (bit 31) of the cr0 reg
    mov cr0, eax

    ret

error:
    ; Print "ERR: X" where X is the value of the `al` register (AKA the error code) 
    mov dword [0xb8000], 0x4f524f45 ; we write directly to `video memory`
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt

; Stack implementation:
section .bss ; https://en.wikipedia.org/wiki/.bss
align 4096 ; Align the tables to 4KB
page_table_l4: ; Root page table
    resb 4096 
page_table_l3:
    resb 4096
page_table_l2: 
    resb 4096
; We don't need a l1 table in this project
stack_bottom:
    resb 4096 * 4 ; 4 pages of 4096 bytes = 16Kb of stack memory 
    ; resb: https://stackoverflow.com/questions/44860003/how-many-bytes-do-resb-resw-resd-resq-allocate-in-nasm
stack_top:

; We need a global descriptor table to map the stack to the CPU.
; It is required to enter 64-bit mode.
section .rodata
gdt64:
    dq 0x0 ; zero entry = NULL descriptor
    ; dq: http://www.tortall.net/projects/yasm/manual/html/nasm-pseudop.html
.code_segment: equ $ - gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; Code segment descriptor, here we enable the executable flag, set the descriptor type to 1 (code&data), present flag, 64-bit flag
.pointer:
    ; Longer pointer that also holds 2 bytes for the length of the table    
    dw $ - gdt64 - 1 ; the label gdt64 references the start of the table
    ; $ special nasm directive equal to the current memory address which is the end of the table
    dq gdt64