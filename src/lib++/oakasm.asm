; oakasm.inc - Oak Assembly Language Framework
; For x86_64 Assembly

%ifndef OAKASM_INC
%define OAKASM_INC

; Constants and Macros for Error Codes
%define OAK_SUCCESS              0
%define OAK_ERROR_MEMORY        1
%define OAK_ERROR_VM            2
%define OAK_ERROR_INSTRUCTION   3
%define OAK_ERROR_STACK         4
%define OAK_ERROR_SEGMENT       5

; Memory Management Constants
%define OAK_PAGE_SIZE           4096
%define OAK_STACK_SIZE         (1024 * 1024)      ; 1MB
%define OAK_HEAP_SIZE          (1024 * 1024 * 16) ; 16MB

; VM States
%define VM_STATE_READY         0
%define VM_STATE_RUNNING       1
%define VM_STATE_PAUSED        2
%define VM_STATE_ERROR         3

; System Call Numbers (Linux x86_64)
%define SYS_READ              0
%define SYS_WRITE             1
%define SYS_OPEN              2
%define SYS_CLOSE             3
%define SYS_MMAP              9
%define SYS_MUNMAP            11
%define SYS_EXIT              60

; Protection Flags for Memory
%define PROT_READ             0x1
%define PROT_WRITE            0x2
%define PROT_EXEC             0x4

; Memory Map Flags
%define MAP_PRIVATE           0x2
%define MAP_ANONYMOUS         0x20

; File Descriptors
%define STDIN                 0
%define STDOUT                1
%define STDERR                2

; Structure Definitions
struc OakVM
    .state:         resq 1    ; Current VM state
    .stack_ptr:     resq 1    ; Stack pointer
    .heap_ptr:      resq 1    ; Heap pointer
    .mem_size:      resq 1    ; Total memory size
    .error_code:    resq 1    ; Last error code
    .flags:         resq 1    ; VM flags
    .registers:     resq 16   ; General purpose registers
endstruc

struc OakMemoryBlock
    .address:       resq 1    ; Memory block address
    .size:          resq 1    ; Block size
    .flags:         resq 1    ; Memory flags
    .next:          resq 1    ; Next block pointer
endstruc

; Macros for VM Operations
%macro OAK_INIT 0
    push rbp
    mov rbp, rsp
    sub rsp, 32             ; Reserve stack space

    ; Initialize VM structure
    mov rdi, OakVM_size     ; Size of VM structure
    call _oak_allocate_memory
    mov [rel vm_instance], rax

    ; Initialize memory management
    call _oak_init_memory

    ; Set initial VM state
    mov qword [rax + OakVM.state], VM_STATE_READY
%endmacro

%macro OAK_CLEANUP 0
    mov rdi, [rel vm_instance]
    call _oak_free_memory
    mov rsp, rbp
    pop rbp
%endmacro

; Error Handling Macro
%macro OAK_ERROR_CHECK 1
    cmp rax, 0
    jl %%error
    jmp %%continue
%%error:
    mov rdi, %1             ; Error message
    call _oak_error_handler
%%continue:
%endmacro

; Memory Allocation Macro
%macro OAK_ALLOC 1
    mov rdi, %1             ; Size to allocate
    call _oak_allocate_memory
    OAK_ERROR_CHECK "Memory allocation failed"
%endmacro

; Memory Protection Macro
%macro OAK_PROTECT_MEMORY 3
    mov rdi, %1             ; Address
    mov rsi, %2             ; Size
    mov rdx, %3             ; Protection flags
    call _oak_protect_memory
%endmacro

; VM Execution Macro
%macro OAK_EXECUTE 1
    mov rdi, %1             ; Instruction pointer
    call _oak_execute
    OAK_ERROR_CHECK "Execution failed"
%endmacro

; Debug Macro
%macro OAK_DEBUG 1
    %ifdef DEBUG
        push rax
        push rcx
        push rdx
        mov rdi, %1         ; Debug message
        call _oak_debug_print
        pop rdx
        pop rcx
        pop rax
    %endif
%endmacro

; External Function Declarations
extern _oak_allocate_memory
extern _oak_free_memory
extern _oak_init_memory
extern _oak_error_handler
extern _oak_protect_memory
extern _oak_execute
extern _oak_debug_print

; Data Section
section .data
    vm_instance:    dq 0    ; Global VM instance pointer
    error_msg:      db "Oak VM Error: ", 0
    debug_msg:      db "Debug: ", 0

; Helper Functions
section .text

; System call wrapper
oak_syscall:
    push rbp
    mov rbp, rsp
    syscall
    pop rbp
    ret

; Memory mapping helper
oak_mmap:
    push rbp
    mov rbp, rsp
    mov rax, SYS_MMAP
    syscall
    cmp rax, -1
    je .error
    pop rbp
    ret
.error:
    mov rax, 0
    pop rbp
    ret

; Example usage:
%macro OAK_PROGRAM_TEMPLATE 0
section .text
global _start

_start:
    OAK_INIT                    ; Initialize Oak VM

    ; Your code here
    OAK_DEBUG "Program started"

    ; Example memory allocation
    OAK_ALLOC 1024

    ; Example execution
    OAK_EXECUTE rax

    ; Cleanup and exit
    OAK_CLEANUP

    mov rax, SYS_EXIT
    xor rdi, rdi                ; Exit code 0
    syscall
%endmacro

%endif ; OAKASM_INC
