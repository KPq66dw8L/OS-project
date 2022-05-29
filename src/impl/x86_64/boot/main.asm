; Virtual memory concept:
; All data in memory is stored at different addresses, however rather
; than working with physical addresses in RAM (slower?), we tipically
; work with virtual addresses. Then mapped to physical addresses by
; the CPU. So the CPU sees virtual addresses.
; Virtual   Physical       Data
; 1 ------> 0xfed50000 --> H
; 2 ------> 0xfed60000 --> E
; 3 ------> 0xfed70000 --> L
; 4 ------> 0xfed80000 --> L
; 5 ------> 0xfed90000 --> O
; Benefits: https://youtu.be/wz9CZBeXR6U?t=472

global start ; To access start when we are linking

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
    ; We do this by creating Page Tables (PTs) and Page Directory (PDs)
    
    ; End `Switch to 64bits mode related`

    ; --------------- Part 1 ---------------
    ; print `OK`
    mov dword [0xb8000], 0x2f4b2f4f ; we write directly to `video memory`, `OK`
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

error:
    ; Print "ERR: X" where X is the value of the `al` register (AKA the error code) 
    mov dword [0xb8000], 0x4f524f45 ; we write directly to `video memory`
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt

; Stack implementation:
section .bss ; https://en.wikipedia.org/wiki/.bss
stack_bottom:
    resb 4096 * 4 ; 4 pages of 4096 bytes = 16Kb of stack memory 
    ; resb: https://stackoverflow.com/questions/44860003/how-many-bytes-do-resb-resw-resd-resq-allocate-in-nasm
stack_top:



