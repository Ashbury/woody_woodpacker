section .text
global _revert_mix

_mul_0e: ; x*14=((((x*2)+x)*2)+x)*2
	push rbp
	mov rbp, rsp
	mov rax, rdi
	shl rax, 1 ; x * 2
	test ah, ah
	je not_overflow1
	xor rax, 0x11b
not_overflow1:
	xor rax, rdi ; + x
	shl rax, 1 ; * 2
	test ah, ah
	je not_overflow2
	xor rax, 0x11b
not_overflow2:
	xor rax, rdi ; + x
	shl rax, 1 ; * 2
	test ah, ah
	je not_overflow3
	xor rax, 0x11b
not_overflow3:
	leave
	ret

_mul_0d:; x*13=((((x*2)+x)*2)*2)+x
	push rbp
	mov rbp, rsp
	mov rax, rdi
	shl rax, 1 ; x * 2
	test ah, ah
	je not_overflow4
	xor rax, 0x11b
not_overflow4:
	xor rax, rdi ; + x
	shl rax, 1 ; x * 2
	test ah, ah
	je not_overflow5
	xor rax, 0x11b
not_overflow5:
	shl rax, 1 ; x * 2
	test ah, ah
	je not_overflow6
	xor rax, 0x11b
not_overflow6:
	xor rax, rdi ; + x
	leave
	ret

_mul_0b: ; x*11=((((x*2)*2)+x)*2)+x
	push rbp
	mov rbp, rsp
	mov rax, rdi
	shl rax, 1 ; x * 2
	test ah, ah
	je not_overflow7
	xor rax, 0x11b
not_overflow7:
	shl rax, 1 ; x * 2
	test ah, ah
	je not_overflow8
	xor rax, 0x11b
not_overflow8:
	xor rax, rdi ; + x
	shl rax, 1 ; x * 2
	test ah, ah
	je not_overflow9
	xor rax, 0x11b
not_overflow9:
	xor rax, rdi ; + x
	leave
	ret

_mul_09: ; x*9=(((x*2)*2)*2)+x
	push rbp
	mov rbp, rsp
	mov rax, rdi
	shl rax, 1 ; x * 2
	test ah, ah
	je not_overflow10
	xor rax, 0x11b
not_overflow10:
	shl rax, 1 ; x * 2
	test ah, ah
	je not_overflow11
	xor rax, 0x11b
not_overflow11:
	shl rax, 1 ; x * 2
	test ah, ah
	je not_overflow12
	xor rax, 0x11b
not_overflow12:
	xor rax, rdi ; + x
	leave
	ret

_revert_mix:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	mov rcx, 0
	mov r12, 0
	mov r13, 0
	mov r14, 0
	mov r15, 0
	mov rdx, rdi
	jmp condition_loop
loop_mix:
	mov r12b, byte [rdx]
	mov r13b, byte [rdx + 1]
	mov r14b, byte [rdx + 2]
	mov r15b, byte [rdx + 3]
	mov rdi, r12
	call _mul_0e
	mov r8, rax
	mov rdi, r13
	call _mul_0b
	mov r9, rax
	mov rdi, r14
	call _mul_0d
	mov r10, rax
	mov rdi, r15
	call _mul_09
	mov r11, rax
;;first:
	xor r8, r9
	xor r10, r11
	xor r8, r10
	mov byte [rdx], r8b
	mov rdi, r12
	call _mul_09
	mov r8, rax
	mov rdi, r13
	call _mul_0e
	mov r9, rax
	mov rdi, r14
	call _mul_0b
	mov r10, rax
	mov rdi, r15
	call _mul_0d
	mov r11, rax
;;snd:
	xor r8, r9
	xor r10, r11
	xor r8, r10
	mov byte [rdx + 1], r8b
	mov rdi, r12
	call _mul_0d
	mov r8, rax
	mov rdi, r13
	call _mul_09
	mov r9, rax
	mov rdi, r14
	call _mul_0e
	mov r10, rax
	mov rdi, r15
	call _mul_0b
	mov r11, rax
;;third:
	xor r8, r9
	xor r10, r11
	xor r8, r10
	mov byte [rdx + 2], r8b
	mov rdi, r12
	call _mul_0b
	mov r8, rax
	mov rdi, r13
	call _mul_0d
	mov r9, rax
	mov rdi, r14
	call _mul_09
	mov r10, rax
	mov rdi, r15
	call _mul_0e
	mov r11, rax
;;fouth:
	xor r8, r9
	xor r10, r11
	xor r8, r10
	mov byte [rdx + 3], r8b
	add rcx, 4
	add rdx, 4
condition_loop:
	cmp rcx, 16
	jl loop_mix
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret