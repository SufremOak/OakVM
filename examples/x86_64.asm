; myprogram.asm
%include "oakasm.inc"

section .data
    message db "Hello from Oak VM!", 10, 0
    msg_len equ $ - message

section .text
global _start

_start:
    OAK_PROGRAM_TEMPLATE        ; Use the template

    ; Custom initialization
    push rbp
    mov rbp, rsp

    ; Allocate memory for program
    OAK_ALLOC 4096
    mov [program_memory], rax

    ; Write message
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, message
    mov rdx, msg_len
    syscall

    ; Execute VM code
    mov rdi, [program_memory]
    OAK_EXECUTE rdi

    ; Exit program
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

section .bss
    program_memory: resq 1
