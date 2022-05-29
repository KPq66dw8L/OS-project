global start ; To access it when we are linking

section .text
bits 32 ; puisque l'on est encore en 32bits mode
start:
    ; print `OK`
    mov dword [0xb8000], 0x2f4b2f4f ; we write directly to `video memory`, `OK`
    hlt
    ; next -> go to /targets (for linking)