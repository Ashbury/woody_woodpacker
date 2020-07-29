section .text
global _shift_rows

_shift_rows:
	push rbp
	mov rbp, rsp
	sub rsp, 0x10
	mov rcx, 0
	mov r10, 4
	mov r11, 16
	mov r8, 0
loop_shift:
	mov rax, r8
	mul r10
	add rax, r8
	mov rdx, 0
	div r11d
	mov rax, rcx
	add rax, rdx
	mov r9b, byte[rdi + rax]
	mov rax, rcx
	add rax, r8
	mov byte [rsp + rax], r9b
	inc r8
	cmp r8, 0x10
	jl loop_shift
	cld
	mov rcx, 16
	lea rsi, [rsp]
	rep movsb
	add rsp, 0x10
	leave
	ret