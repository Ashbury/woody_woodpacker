section .text
global _generate_extend_key
extern _generation_s_box
extern _malloc
extern _substitute_column
extern _rotate_column
extern _rcon_round

_generate_extend_key: ;; rdi -> key ;; rsi -> sbox
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	sub rsp, 0x28 ;; rsp -> s_box
	mov qword [rsp], rsi
	mov r12, rdi
	mov rdi, qword [rsp]
	call _generation_s_box
	mov r13, 8 ;; numer_round
	mov r14, 28 ;; idx
	mov byte [rsp + 0x10], 1
loop_extend_key:
	mov rdx, 0
	mov ecx, 4
	mov rax, r13
	div ecx
	test edx, edx
	jne third_case
	mov rdi, qword [rsp]
	mov r10, r12
	add r10, r14
	mov rsi, r10
	call _substitute_column
	mov r9d, eax
	mov rdx, 0
	mov ecx, 8
	mov rax, r13
	div ecx
	test edx, edx
	jne continue
	mov edi, r9d
	call _rotate_column
	mov rdi, 0
	mov dil, byte [rsp + 0x10]
	mov rsi, rax
	mov r8b, dil
	inc r8b
	mov byte [rsp + 0x10], r8b
	call _rcon_round
	mov r9d, eax
	jmp continue
third_case:
	mov r9d, dword[r12 + r14]
continue:
	add r14, 4
	mov r10d, dword[r12 + r14 - 32]
	xor r9d, r10d
	mov dword [r12 + r14], r9d
	inc r13
	cmp r13, 60
	jne loop_extend_key
	add rsp, 0x20
	pop r14
	pop r13
	pop r12
	leave
	ret
