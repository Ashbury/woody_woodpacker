section .text
global _rcon_round
global _rci

_rci:
	push rbp
	mov rbp, rsp
	mov rax, 1
	cmp rdi, 1
	je end_rci
	dec rdi
	call _rci
	mov rcx, 2
	cmp rax, 0x80
	jl lower_case
	mul cx
	xor ax, 0x11b
	jmp end_rci
lower_case:
	mul cx
end_rci:
	leave
	ret

_rcon_round:
	push rbp
	mov rbp, rsp
	call _rci
	xor eax, esi
	leave
	ret