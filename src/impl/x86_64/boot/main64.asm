global long_mode_start ; So that main.asm can access it.

section .text
bits 64 ; Setting the default alignment to 64-bit. AKA the bits to 64.
long_mode_start:
    ; load null into all data segment registers 
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax 

    ; --------------- Part 2 (printing part) ---------------
    mov dword [0xb8000], 0x2f4b2f4f ; moved from Part 1
    hlt
    ; --------------- End Part 2 (printing part) ---------------