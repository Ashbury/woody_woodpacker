section .text
global _encode_size

_encode_size:
	push rbp
	mov rbp, rsp
	mov r8, qword[rdi + 24]
	cmp rsi, 0x0F
	jl end_encode_size
	sub rsi, 0x0F
	jmp condition_loop
loop_size:
	mov byte[r8], 0xFF
	sub rsi, 0xFF
	inc r8
condition_loop:
	cmp rsi, 0xFF
	jge loop_size
	mov byte[r8], sil
	inc r8
	mov qword[rdi + 24], r8
end_encode_size:
	leave
	ret