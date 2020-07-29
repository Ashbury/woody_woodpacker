section .text
global _lz4_hc
%ifdef DARWIN
extern _malloc
%else
extern malloc
%endif
extern _find_matches

_lz4_hc:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov qword[rdi], rdx
	mov qword[rsp], rsi					;; -> offset begin data
	mov qword[rsp + 8], rsi				;; -> offset begin literal
	add rsi, rdx
	mov qword[rsp + 16], rsi			;; -> max offset
	mov qword[rsp + 32], rdi			;; -> encrypted buffer
	add rdi, 16
	mov qword[rsp + 24], rdi			;; -> current offset of encrypted buffer
	lea rdi, [rsp]
	call _find_matches
	mov rax, qword[rsp + 32]
	mov rdx, qword[rsp + 24]
	mov rcx, rdx
	sub rcx, rax
	mov qword[rax + 8], rcx				;; -> begin of buffer is set at encrypted buffer's size
	leave
	ret
