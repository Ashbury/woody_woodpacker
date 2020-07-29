section .text
global _subbyte_sbox

_subbyte_sbox:
	push rbp
	mov rbp, rsp
	mov rcx, 0
substitute:
	mov rax, 0
	mov al, byte [rdi + rcx]
	mov al, byte [rsi + rax]
	mov byte [rdi + rcx], al
	inc rcx
	cmp rcx, 16
	jne substitute
	leave
	ret