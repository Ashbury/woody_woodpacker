section .text
global _encode_litteral_size
extern _encode_size

_encode_litteral_size:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	mov r12, rdi
	mov r13, rsi
	call _encode_size
	cld
	mov rcx, r13
	mov rdi, qword[r12 + 24]
	mov rsi, qword[r12 + 8]
	rep movsb
	mov qword[r12 + 24], rdi
	mov qword[r12 + 8], rsi
	pop r13
	pop r12
	leave
	ret
