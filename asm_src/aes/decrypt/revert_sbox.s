section .text
global _revert_sbox

_revert_sbox:
	push rbp
	mov rbp, rsp
	mov rdx, 0
	mov r8, rdi
loop_sub:
	mov rax, 0
	mov al, byte [r8 + rdx]
	mov rcx, 0x100
	mov rdi, rsi
	repne scasb
	not rcx
	mov byte [r8 + rdx], cl
	inc rdx
	cmp rdx, 16
	jne loop_sub
	leave
	ret