section .text
global _decompress_lz4
extern _decompress

_decompress_lz4:
	push rbp
	mov rbp, rsp
	mov rdx, qword[rsi + 8]
	add rdx, rsi
	add rsi, 16
	call _decompress
	leave
	ret