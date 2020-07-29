section .text
global _find_matches
extern _new_packet
extern _last_packet

;; rdi ->data
;; r8 -> match
;; r9 -> chr_match
;; [rsp] -> size_find
;; [rsp + 8] -> *match_1
;; [rsp + 16] -> *match_2

_find_matches:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov r8, qword[rdi + 8] ;; match = data->offset_begin_litteral;
	mov qword[rsp], 0 ;; size_find = 0;
	mov qword[rsp + 8], 0 ;; match_1 = 0;
	mov qword[rsp + 16], 0 ;; match_2 = 0;
	jmp cond_loop1
loop1:
	mov r9, r8
	sub r9, 8
	jmp cond_loop2
loop2:
	mov r10d, dword[r8]
	mov r11d, dword[r9]
	cmp r10d, r11d
	jne not_match
	mov r10, rdi
	mov rcx, qword[rdi + 16]
	sub rcx, r8 ;; max_len_match = data->max_offset - match + 1
	inc rcx
;;cmp_match:
	mov rsi, r8
	mov rdi, r9
	repe cmpsb
	sub rdi, r9 ;; len match
	mov r11, qword[rsp]
	dec rdi
	cmp rdi, r11
	jle no_new_match
	mov qword[rsp], rdi
	mov qword[rsp + 8], r9
	mov qword[rsp + 16], r8
no_new_match:
	mov rdi, r10
not_match:
	dec r9
cond_loop2:
	mov r11, qword[rdi] ;; data->offset_begin_data
	cmp r9, r11 ;; chr_match >= data->offset_begin_data
	jl end_loop2
	mov r10, r8
	sub r10, r9
	and r10, 0xffffffffffff0000
	test r10, r10 ;; (size_t)match - (size_t)chr_match <= 65535
	je loop2
end_loop2:
	inc r8
cond_loop1:
	mov r10, qword[rsp + 16] ;; match_2
	mov r11, r8 ;; match
	sub r11, r10
	cmp r11, 4 ;; match - match_2 != 4
	je end_loop1
	mov r11, r8
	add r11, 4 ;; match + 4
	mov r10, qword[rdi + 16] ;; data->max_offset
	cmp r11, r10 ;; match + 4 < data->max_offset
	jl loop1
end_loop1:
	mov r10, qword[rsp]
	test r10, r10
	jne call_new_packet
	call _last_packet
	jmp end_find
call_new_packet:
	mov rsi, qword[rsp]
	mov rdx, qword[rsp + 8]
	mov rcx, qword[rsp + 16]
	call _new_packet
end_find:
	add rsp, 32
	leave
	ret
