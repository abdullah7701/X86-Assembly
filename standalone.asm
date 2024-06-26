section .bss
    parent resq 65536        ; Array to store the parent of each element
    rank resq 65536          ; Array to store the rank of each element
    solution_string resb 256 ; Buffer to store the solution string

section .data
    instruction_string db 'U0&1 U1&2 F2 F0', 0
    instr_ptr dq 0           ; Pointer to the current instruction
    sol_ptr dq 0             ; Pointer to the solution string
    space db ' ', 0
    plus db '+', 0
    minus db '-', 0

section .text
    global _start

_start:
    ; Set up initial parameters
    mov rdi, 3                          ; setSize
    mov rsi, instruction_string         ; instruction_string
    mov rdx, solution_string            ; solution_string

    ; Call unionfind function
    call unionfind

    ; Print the solution string
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; file descriptor: stdout
    mov rsi, solution_string
    mov rdx, 256
    syscall

    ; Exit the program
    mov rax, 60         ; syscall: exit
    xor rdi, rdi        ; status: 0
    syscall

unionfind:
    ; Arguments: rdi = setSize, rsi = instruction_string, rdx = solution_string
    ; Save pointers to instruction string and solution string
    mov [instr_ptr], rsi
    mov [sol_ptr], rdx

    ; Initialize parent and rank arrays
    xor rax, rax
init_loop:
    mov qword [parent + rax*8], rax
    mov qword [rank + rax*8], 1
    inc rax
    cmp rax, rdi
    jl init_loop

    ; Main processing loop
process_loop:
    ; Skip spaces in instruction string
    call skip_spaces

    ; Check if the instruction string is finished
    mov rsi, [instr_ptr]
    cmp byte [rsi], 0
    je end_process

    ; Read the instruction type
    mov al, [rsi]
    inc rsi
    mov [instr_ptr], rsi

    ; Handle Union instruction
    cmp al, 'U'
    je handle_union

    ; Handle Find instruction
    cmp al, 'F'
    je handle_find

    ; Invalid instruction (should not happen)
    jmp process_loop

handle_union:
    ; Skip the '&' character
    call skip_spaces
    inc qword [instr_ptr]

    ; Read the first operand
    call getint
    mov rbx, rax

    ; Skip spaces and '&' character
    call skip_spaces
    inc qword [instr_ptr]

    ; Read the second operand
    call getint
    mov rcx, rax

    ; Perform Union operation
    call find
    mov rdx, rax
    mov rax, rbx
    call find
    mov rbx, rax

    cmp rbx, rdx
    je handle_union_end

    mov rsi, rbx
    mov rdi, rdx
    call union

    ; Append 'U' to solution string
    mov rsi, [sol_ptr]
    mov byte [rsi], 'U'
    inc rsi
    mov [sol_ptr], rsi

    ; Append result to solution string
    call putint
    ; Add '+' if rank grew
    cmp r8, 1
    jne no_plus
    mov rsi, [sol_ptr]
    mov al, [plus]
    stosb
    mov [sol_ptr], rsi
no_plus:
    call append_level
    jmp process_loop

handle_union_end:
    ; Skip the rest of the instruction string
    call skip_to_space
    jmp process_loop

handle_find:
    ; Read the operand
    call getint
    mov rbx, rax

    ; Perform Find operation
    call find
    mov rbx, rax

    ; Append 'F' to solution string
    mov rsi, [sol_ptr]
    mov byte [rsi], 'F'
    inc rsi
    mov [sol_ptr], rsi

    ; Append result to solution string
    call putint
    call append_level

    jmp process_loop

end_process:
    ret

find:
    ; Arguments: rax = element
    mov rdx, rax
    xor rcx, rcx
find_loop:
    mov rbx, [parent + rax*8]
    cmp rbx, rax
    je found
    mov rax, rbx
    inc rcx
    jmp find_loop
found:
    mov rdi, rdx
    mov rsi, rax
    call relink
    mov rax, rsi
    mov r8, rcx
    ret

relink:
    ; Arguments: rdi = element, rsi = representative
    mov rbx, [parent + rdi*8]
    cmp rbx, rsi
    je relink_done
    mov rax, [parent + rbx*8]
    mov [parent + rdi*8], rax
relink_done:
    ret

union:
    ; Arguments: rsi = representative1, rdi = representative2
    mov rax, [rank + rsi*8]
    mov rbx, [rank + rdi*8]
    cmp rax, rbx
    jl union_case1
    jg union_case2
    ; Equal rank case
    inc rax
    mov [rank + rsi*8], rax
    mov [parent + rdi*8], rsi
    mov r8, 1
    ret
union_case1:
    mov [parent + rsi*8], rdi
    mov r8, 0
    ret
union_case2:
    mov [parent + rdi*8], rsi
    mov r8, 0
    ret

skip_spaces:
    mov rsi, [instr_ptr]
skip_loop:
    cmp byte [rsi], ' '
    jne skip_end
    inc rsi
    jmp skip_loop
skip_end:
    mov [instr_ptr], rsi
    ret

skip_to_space:
    mov rsi, [instr_ptr]
skip_to_space_loop:
    cmp byte [rsi], ' '
    je skip_to_space_end
    inc rsi
    jmp skip_to_space_loop
skip_to_space_end:
    mov [instr_ptr], rsi
    ret

append_level:
    ; Append 'L' to solution string
    mov rsi, [sol_ptr]
    mov byte [rsi], 'L'
    inc rsi
    mov [sol_ptr], rsi

    ; Append level count to solution string
    mov rax, r8
    call putint

    ; Append '-' if relinking occurred
    cmp r8, 0
    je no_minus
    mov rsi, [sol_ptr]
    mov al, [minus]
    stosb
    mov [sol_ptr], rsi
no_minus:
    ; Append space to solution string
    mov rsi, [sol_ptr]
    mov al, [space]
    stosb
    mov [sol_ptr], rsi

    ret

getint:
    ; Arguments: rsi = pointer to input string
    xor rax, rax
getint_loop:
    movzx rcx, byte [rsi]
    cmp rcx, '0'
    jb getint_done
    cmp rcx, '9'
    ja getint_done
    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx
    inc rsi
    jmp getint_loop
getint_done:
    mov [instr_ptr], rsi
    ret

putint:
    ; Arguments: rax = number, rsi = pointer to output string
    mov rbx, 10
    mov rcx, 0
    mov rdx, rsi
    add rdx, 20         ; move pointer forward to store digits in reverse

putint_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rcx
    mov [rsi + rcx], dl
    test rax, rax
    jnz putint_loop

    add rsi, rcx
    ret
