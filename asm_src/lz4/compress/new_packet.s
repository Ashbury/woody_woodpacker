section .text
global _new_packet
extern _encode_litteral_size
extern _encode_size
extern _find_matches

_new_packet:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	mov r12, rsi
	mov r13, rdi
	mov r14, rdx
	sub r12, 4
	mov r8, rcx
	mov r9, qword[rdi + 8]
	sub r8, r9 ;; literal_size = (size_t)match - (size_t)data->offset_begin_litteral;
	mov rsi, r8 ;; arg for encode_litteral_size
	cmp r8, 0x0F
	jl set_token_litteral
	mov r8, 0x0F
set_token_litteral:
	shl r8, 4
	mov r9, r12
	cmp r9, 0x0F
	jl set_token_match
	mov r9, 0x0F
set_token_match:
	or r8, r9
	mov r9, qword[rdi + 24]
	mov byte[r9], r8b
	inc r9
	mov qword[rdi + 24], r9
	call _encode_litteral_size
	mov r8, qword[r13 + 8]
	sub r8, r14
	mov r9, qword[r13 + 24]
	mov word[r9], r8w
	add r9, 2
	mov qword[r13 + 24], r9
	mov r9, qword[r13 + 8]
	add r9, r12
	add r9, 4
	mov qword[r13 + 8], r9
	mov rdi, r13
	mov rsi, r12
	call _encode_size
	mov rdi, r13
	call _find_matches
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret