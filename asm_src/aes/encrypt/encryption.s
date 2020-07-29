section .text
global _encryption
extern _generation_s_box
extern _generate_extend_key
extern _add_round_key
extern _subbyte_sbox
extern _shift_rows
extern _mix_column

_encryption:
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
	mov rsi, r12
	call _add_round_key
	mov r14, 0
	jmp cond_loop
loop_round:
	mov rdi, r13
	mov rsi, r15
	call _subbyte_sbox
	mov rdi, r13
	call _shift_rows
	mov rdi, r13
	call _mix_column
	mov rdi, r13
	inc r14
	mov rsi, r14
	shl rsi, 4
	mov r9, r12
	add rsi, r9
	call _add_round_key
cond_loop:
	cmp r14, 13
	jl loop_round
	mov rdi, r13
	mov rsi, r15
	call _subbyte_sbox
	mov rdi, r13
	call _shift_rows
	mov rdi, r13
	mov rsi, 14
	shl rsi, 4
	mov r9, r12
	add rsi, r9
	call _add_round_key
	; add rsp, 504
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret