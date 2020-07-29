section .text
global _add_round_key

_add_round_key:
	push rbp
	mov rbp, rsp
	mov r10, qword[rdi]
	mov r11, qword[rsi]
	xor r10, r11
	mov qword[rdi], r10
	mov r10, qword[rdi + 8]
	mov r11, qword[rsi + 8]
	xor r10, r11
	mov qword[rdi + 8], r10
	leave
	ret