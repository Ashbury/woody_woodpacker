section .text
global _decryption
extern _generation_s_box
extern _generate_extend_key
extern _add_round_key
extern _revert_sbox
extern _revert_shift_rows
extern _revert_mix

_decryption:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	mov r12, rdi
	mov r13, rsi
	mov r15, rdx
	mov rdi, r13
	mov rsi, 14
	shl rsi, 4
	mov r9, r12
	add rsi, r9
	call _add_round_key
	mov r14, 13
	jmp cond_loop
loop_round:
	mov rdi, r13
	call _revert_shift_rows
	mov rdi, r13
	mov rsi, r15
	call _revert_sbox
	mov rdi, r13
	mov rsi, r14
	shl rsi, 4
	mov r8, r12
	add rsi, r8
	call _add_round_key
	mov rdi, r13
	call _revert_mix
	dec r14
cond_loop:
	cmp r14, 0
	jg loop_round
	mov rdi, r13
	call _revert_shift_rows
	mov rdi, r13
	mov rsi, r15
	call _revert_sbox
	mov rdi, r13
	mov rsi, r12
	call _add_round_key
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret