section .data
 
section .bss
 
section .text
    global print_string, read_string, convert_password
 
print_string:
    ; Entrada: EAX = ponteiro para string
    pusha
    mov ecx, eax
    mov edx, 0
.next_char:
    cmp byte [ecx + edx], 0
    je .done
    inc edx
    jmp .next_char
.done:
    mov eax, 4
    mov ebx, 1
    int 0x80
    popa
    ret
 
read_string:
    ; Entrada: EAX = buffer onde será armazenada a string
    pusha
    mov edx, 10
    mov ecx, eax
    mov eax, 3
    mov ebx, 0
    int 0x80
    popa
    ret
 
convert_password:
    ; Entrada: EAX = ponteiro para a senha
    ; Saída: EAX = ponteiro para a senha convertida
    pusha
    mov esi, eax
.next_char:
    cmp byte [esi], 0
    je .done
    add byte [esi], 1
    inc esi
    jmp .next_char
.done:
    mov eax, esi
    popa
    ret
section .data
    prompt db 'Por favor, entre com a senha: ', 0
    prompt_again db 'Entre com a senha novamente: ', 0
    success db 'Senha alterada com sucesso!', 0
    failure db 'Erro: Senhas nao conferem.', 0
    stored_password db 10 dup(0)
 
section .bss
    password1 resb 10
    password2 resb 10
 
section .text
    extern print_string, read_string, convert_password
    global _start
 
_start:
    ; Primeira entrada de senha
    call prompt_for_password
    mov eax, password1
    call read_string
 
    ; Segunda entrada de senha
    call prompt_for_password_again
    mov eax, password2
    call read_string
 
    ; Verifica se as senhas são iguais
    mov esi, password1
    mov edi, password2
    mov ecx, 10
    repe cmpsb
    jnz passwords_do_not_match
 
    ; Converte a senha para armazenamento
    mov eax, password1
    call convert_password
    mov esi, eax
    mov edi, stored_password
    mov ecx, 10
    rep movsb
 
    ; Mensagem de sucesso
    call print_success
    jmp end_program
 
passwords_do_not_match:
    ; Mensagem de erro
    call print_failure
 
end_program:
    ; Saída do programa
    mov eax, 1          ; syscall number (sys_exit)
    xor ebx, ebx        ; exit code 0
    int 0x80
 
prompt_for_password:
    mov eax, prompt
    call print_string
    ret
 
prompt_for_password_again:
    mov eax, prompt_again
    call print_string
    ret
 
print_success:
    mov eax, success
    call print_string
    ret
 
print_failure:
    mov eax, failure
    call print_string
    ret
