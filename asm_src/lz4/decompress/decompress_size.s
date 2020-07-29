section .text
global _decompress_size

_decompress_size:
	push rbp
	mov rbp, rsp
	mov r8, qword[rdi]
	cmp rsi, 0x0F
	jl end_decode_size
	jmp condition_dloop
loop_dsize:
	add rsi, 0xFF
	inc r8
condition_dloop:
	cmp byte[r8], 0xFF
	je loop_dsize
	mov r9, 0
	mov r9b, byte[r8]
	add rsi, r9
	inc r8
	mov qword[rdi], r8
end_decode_size:
	mov rax, rsi
	leave
	ret