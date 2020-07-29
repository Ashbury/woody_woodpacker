section .text
global _decompress
extern _decompress_size

;; [rsp] -> dest
;; [rsp + 8] -> src
;; r12 -> match_lenght / offset
;; r13 -> end_src

_decompress:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	sub rsp, 16
	cmp rsi, rdx
	jge end_decompress
	mov qword[rsp], rdi
	mov qword[rsp + 8], rsi
	mov r13, rdx
	xor r8, r8
	mov r8b, byte[rsi]
	mov r12, r8
	shr r8, 4 ;; literal_lenght = *src >> 4;
	mov rsi, r8
	and r12, 0x0f ;; match_lenght = (*src & 0x0F);
	lea rdi, [rsp + 8]
	lea rdi, [rdi]
	mov r8, qword[rsp + 8]
	inc r8
	mov qword[rsp + 8], r8
	call _decompress_size ;; rax -> literal_lenght
	cld
	mov rdi, qword[rsp]
	mov rsi, qword[rsp + 8]
	mov rcx, rax
	rep movsb		;; memcpy(dest, src, literal_lenght);
					;; dest += literal_lenght;
					;; src += literal_lenght;
	mov qword[rsp], rdi
	mov qword[rsp + 8], rsi
	cmp rsi, r13
	jge end_decompress
	mov rsi, r12
	xor r12, r12
	mov r8, qword[rsp + 8]
	mov r12w, word[r8] ;; uint16_t offset = *((uint16_t*)src);
	add r8, 2
	mov qword[rsp + 8], r8
	lea rdi, [rsp + 8]
	lea rdi, [rdi]
	call _decompress_size
	cld
	mov rdi, qword[rsp]
	mov rsi, rdi
	sub rsi, r12
	mov rcx, rax
	add rcx, 4
	rep movsb
	mov rsi, qword[rsp + 8]
	mov rdx, r13
	call _decompress
end_decompress:
	add rsp, 16
	pop r13
	pop r12
	leave
	ret
