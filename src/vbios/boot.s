;==================================================
; Simple BIOS Implementation in x86 Assembly
;==================================================

org 0x7C00      ; Standard boot sector origin

start:
    cli         ; Disable interrupts
    xor ax, ax  ; Zero AX
    mov ds, ax  ; Set up segments
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti         ; Enable interrupts

init_video:
    mov ah, 0x00    ; Set video mode
    mov al, 0x03    ; 80x25 text mode
    int 0x10

print_msg:
    mov si, msg     ; Load message
    mov ah, 0x0E    ; BIOS teletype output

print_char:
    lodsb           ; Load next character
    or al, al       ; Check for end of string
    jz halt         ; If zero, end program
    int 0x10        ; Print character
    jmp print_char

halt:
    cli             ; Disable interrupts
    hlt             ; Halt the system

msg db 'Basic BIOS loaded...', 0x0D, 0x0A, 0

times 510-($-$$) db 0   ; Pad with zeros
dw 0xAA55              ; Boot signature
