section .text
global _last_packet
extern _encode_litteral_size

_last_packet:
	push rbp
	mov rbp, rsp
	mov r8, qword[rdi + 16]
	mov r9, qword[rdi + 8]
	sub r8, r9
	mov rsi, r8
	cmp r8, 0x0F
	jle set_token
	mov r8b, 0x0F
set_token:
	shl r8b, 4
	mov r9, qword[rdi + 24]
	mov byte[r9], r8b
	inc r9
	mov qword[rdi + 24], r9
	call _encode_litteral_size
	leave
	ret