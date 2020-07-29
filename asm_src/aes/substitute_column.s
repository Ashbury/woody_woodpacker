section .text
global _substitute_column

_substitute_column:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rcx, 0
substitute:
	lea r8, [rsp]
	mov rax, 0
	mov al, byte [rsi + rcx]
	mov al, byte [rdi + rax]
	mov byte [r8 + rcx], al
	inc rcx
	cmp rcx, 4
	jne substitute
	mov eax, dword [r8]
	add rsp, 16
	leave
	ret