section .multiboot_header
; For the boot loader to be able to know that there is a kernel
; The units: https://stackoverflow.com/questions/10168743/which-variable-size-to-use-db-dw-dd-with-x86-assembly
header_start:
    ; magic number
    dd 0xe85250d6 ; multiboot2 -> https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#Header-magic-fields
    ; architecture 
    dd 0 ; 32-bit (protected) mode of i386
    ; header_length
    dd header_end - header_start
    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; end tag
    dw 0 
    dw 0
    dd 8
header_end: