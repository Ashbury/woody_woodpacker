section .text

global _start
global _main
extern _generate_extend_key
extern _decryption
extern _decompress_lz4

_start:
_main:
	push rbp
	mov rbp, rsp
	push rax
	push rcx
	push rdx
	push rbx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	mov rdi, 0xaaaaaaaaaaaaaaaa ;; addr old_entry_point
	mov rsi, 0xdddddddddddddddd ;; addr new_entry_point
	mov r8, r12
	sub r8, rsi
	add rdi, r8
	push rdi
	mov rdi, 0xcccccccccccccccc ;; addr .text
	add rdi, r8
	push rdi
	sub rsp, 0x210 ;;240 + 256 + 16 + align;; [rsp] -> key ; [rsp + 0xf0] -> sbox ; [rsp + 0x1f0] -> str_woody ; [rsp + 0x210]? -> addr str
; decrypt_aes:
	mov rax, 0xbbbbbbbbbbbbbbbb
	mov qword[rsp], rax
	mov rax, 0xbbbbbbbbbbbbbbbb
	mov qword[rsp + 0x08], rax
	mov rax, 0xbbbbbbbbbbbbbbbb
	mov qword[rsp + 0x10], rax
	mov rax, 0xbbbbbbbbbbbbbbbb
	mov qword[rsp + 0x18], rax ;; key
	lea rdi, [rsp]
	lea rsi, [rsp + 0xf0]
	call _generate_extend_key
	lea rdi, [rsp]
	mov rsi, qword[rsp + 0x210] ;; addr .text
	lea rdx, [rsp + 0xf0]
	call _decryption
	mov r8, qword[rsp + 0x210]
	mov r12, 0xeeeeeeeeeeeeeeee;;qword[r8 + 8] ;; compressed size
	mov r14, r12
	mov r13, r8
	jmp cond_loop
beg_loop:
	sub r14, 16
	add r13, 16
	lea rdi, [rsp]
	mov rsi, r13
	lea rdx, [rsp + 0xf0]
	call _decryption
cond_loop:
	cmp r14, 32
	jge beg_loop
;;end_aes:
; 	mov r8, qword[rsp + 0x210]
; 	mov rdi, qword[r8] ;; decompressed size
; 	mov r13, rdi
; 	mov r12, rdi
; 	and r12, 0xfffffffffffff000
; 	add r12, 0x1000
; 	mov rax, 0x646f6f772e2e2e2e
; 	mov qword[rsp + 0x1f0], rax
; 	mov rax, 0x00000a2e2e2e2e79
; 	mov qword[rsp + 0x1f0], rax
; 	mov rax, 9
; 	mov rdi, 0
; 	mov rsi, r12
; 	mov rdx, 3
; 	mov r10, 0x22
; 	mov r8, -1
; 	mov r9, 0
; call_mmap:
; 	syscall ;; mmap
; 	jc exit_error
; 	; and rdi, 0xfffffffffffffff0
; 	; add rdi, 0x10
; 	; mov r13, rdi
; 	; sub rsp, rdi
; 	; and rsp, 0xfffffffffffffff0
; 	mov r12, rax
; 	mov rdi, r12
; 	mov rsi, qword[rsp + 0x210]
; 	call _decompress_lz4
; 	cld
; 	mov rdi, qword[rsp + 0x210]
; 	mov rsi, r12
; 	mov rcx, r13
; 	rep movsb ;; cpy decompressed buffer at compressed buffer
; 	mov rax, 0x0b
; 	mov rdi, r12
; 	mov rsi, r13
; 	syscall ;; munmap
	mov rax, 0x646f6f772e2e2e2e
	mov qword[rsp + 0x1f0], rax
	mov rax, 0x00000a2e2e2e2e79
	mov qword[rsp + 0x1f8], rax
	mov rax, 1
	mov rdi, 1
	lea rsi, [rsp + 0x1f0]
	mov rdx, 14
	syscall ;; write
	; mov r8, r13
	; and r8, 0xf
	; mov r9, 0x10
	; sub r9, r8
	; add r13, r9
	; add rsp, r13
	add rsp, 0x218
	pop r12
	pop r15
	pop r14
	pop r13
	add rsp, 0x8
	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rsi
	pop rbx
	pop rdx
	pop rcx
	pop rax
bef_jmp:
	pop rbp
	jmp r12
exit_error:
	mov rax, 60
	xor rdi, rdi
	syscall ;; exit