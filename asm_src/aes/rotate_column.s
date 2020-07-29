section .text
global _rotate_column

_rotate_column:
	push rbp
	mov rbp, rsp
	mov rax, 0
	mov rdx, 0
	mov eax, edi
	mov edx, edi
	shr eax, 8
	shl edx, (32 - 8)
	or eax, edx
	leave
	ret