section .text
global _mix_column

_mix_column:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	mov rcx, 0
	mov r8, 0
	mov r9, 0
	mov r10, 0
	mov r11, 0
	jmp condition_loop
loop_mix:
	mov rdx, rdi
	add rdx, rcx
	mov r8b, byte [rdx]
	mov r9b, byte [rdx + 1]
	mov r10b, byte [rdx + 2]
	mov r11b, byte [rdx + 3]
	mov r12, r8
	shl r12, 1
	mov rax, r8
	shr rax, 7
	test rax, rax
	je next
	xor r12, 0x1b
next:
	mov r13, r9
	shl r13, 1
	mov rax, r9
	shr rax, 7
	test rax, rax
	je next1
	xor r13, 0x1b
next1:
	mov r14, r10
	shl r14, 1
	mov rax, r10
	shr rax, 7
	test rax, rax
	je next2
	xor r14, 0x1b
next2:
	mov r15, r11
	shl r15, 1
	mov rax, r11
	shr rax, 7
	test rax, rax
	je next3
	xor r15, 0x1b
next3:
	mov rax, r13 ;; * 3
	xor rax, r9
	xor rax, r12 ;; * 2
	xor rax, r10
	xor rax, r11
	mov byte [rdx], al
	mov rax, r14 ;; * 3
	xor rax, r10
	xor rax, r13 ;; * 2
	xor rax, r8
	xor rax, r11
	mov byte [rdx + 1], al
	mov rax, r15 ;; * 3
	xor rax, r11
	xor rax, r14 ;; * 2
	xor rax, r8
	xor rax, r9
	mov byte [rdx + 2], al
	mov rax, r12 ;; * 3
	xor rax, r8
	xor rax, r15 ;; * 2
	xor rax, r10
	xor rax, r9
	mov byte [rdx + 3], al
	add rcx, 4
condition_loop:
	cmp rcx, 16
	jl loop_mix
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret