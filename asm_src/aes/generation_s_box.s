section .text
global _generation_s_box

%macro CIRCULAR_SHIFT 1
	mov r10b, r9b
	mov r11b, r9b
	shl r10b, %1
	shr r11b, (8 - %1)
	or r10b, r11b
%endmacro

_generation_s_box:
	push rbp
	mov rbp, rsp
	mov r8, 0
	mov r9, 0
	mov r8b, 1 ;; -> idx tab
	mov r9b, 1 ;; -> seed -> idx * seed = 1
	mov r10, 0
	mov r11, 0
generation_loop:
;;calcul_idx: ;; idx = idx ^ (idx << 1) ^ ((idx & 0x80) ? 0x1B : 0)
	mov al, r8b
	mov cl, r8b
	shl cl, 1
	xor al, cl
	mov cl, 0
	and r8b, 0x80
	jz r8b_inf_0x80
	mov cl, 0x1B
r8b_inf_0x80:
	xor al, cl
	mov r8b, al
;;calcul_seed: ;; seed ^= seed << 1; seed ^= seed << 2; seed ^= seed << 4; seed ^= (seed & 0x80) ? 0x09 : 0;
	mov al, r9b
	mov cl, r9b
	shl cl, 1
	xor al, cl
	mov cl, al
	shl cl, 2
	xor al, cl
	mov cl, al
	shl cl, 4
	xor al, cl
	mov cl, al
	mov r9b, 0
	and cl, 0x80
	jz cl_inf_0x80
	mov r9b, 0x09
cl_inf_0x80:
	xor al, r9b
	mov r9b, al
;;calcul_value: ;; calcul s_box
	mov sil, r9b
	CIRCULAR_SHIFT 1
	xor sil, r10b
	CIRCULAR_SHIFT 2
	xor sil, r10b
	CIRCULAR_SHIFT 3
	xor sil, r10b
	CIRCULAR_SHIFT 4
	xor sil, r10b
	xor sil, 0x63
	mov rax, 0
	mov al, r8b
	mov byte [rdi + rax], sil
	cmp r8b, 1
	jne generation_loop
	mov byte [rdi], 0x63
	leave
	ret