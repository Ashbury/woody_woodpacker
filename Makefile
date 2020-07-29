NAME_WOODY = woody_woodpacker

BINARY_DECRYPT = decrypt

DUMP_SHELLCODE = dump_shell

CFLAGS = -Wall -Wextra -Werror

LIBFT_PATH = libft

SRC_WOODY = main.c encrypt_text_section.c parse_file.c create_woody.c

SRC_DECRYPTION = decryption_main.s

SRC_ASM_AES = generation_s_box.s substitute_column.s rotate_column.s\
			  generate_extend_key.s rcon_round.s add_round_key.s

SRC_ASM_AES_ENCRYPT = mix_column.s shift_rows.s subbyte_sbox.s encryption.s

SRC_ASM_AES_DECRYPT = revert_mix.s revert_sbox.s revert_shift_rows.s decryption.s

OBJ_WOODY = $(addprefix obj/, $(SRC_WOODY:.c=.o))

OBJ_DECRYPTION = $(addprefix obj/, $(SRC_DECRYPTION:.s=.o))

OBJ_ASM_AES = $(addprefix obj/, $(SRC_ASM_AES:.s=.o))

OBJ_ASM_AES_ENCRYPT = $(addprefix obj/, $(SRC_ASM_AES_ENCRYPT:.s=.o))

OBJ_ASM_AES_DECRYPT = $(addprefix obj/, $(SRC_ASM_AES_DECRYPT:.s=.o))

INC = includes

INCLUDE_WOODY = $(INC)/aes.h $(INC)/woody_woodpacker.h

all : obj $(NAME_WOODY) $(BINARY_DECRYPT)
	@echo "$(NAME_WOODY) OK"

obj :
	@mkdir -p obj

obj/%.o: srcs/%.c $(INCLUDE_WOODY)
	clang $(CFLAGS) -c $< -o $@ -I $(INC) -I $(LIBFT_PATH)/includes

obj/%.o: asm_src/%.s
	nasm -f elf64 $< -o $@

obj/%.o: asm_src/aes/%.s
	nasm -f elf64 $< -o $@

obj/%.o: asm_src/aes/encrypt/%.s
	nasm -f elf64 $< -o $@

obj/%.o: asm_src/aes/decrypt/%.s
	nasm -f elf64 $< -o $@

$(NAME_WOODY) : obj $(OBJ_WOODY) $(OBJ_ASM_AES) $(OBJ_ASM_AES_ENCRYPT)
	make -C $(LIBFT_PATH)
	clang -o $(NAME_WOODY) $(OBJ_WOODY) $(OBJ_ASM_AES) $(OBJ_ASM_AES_ENCRYPT) $(LIBFT_PATH)/libft.a

$(BINARY_DECRYPT) : $(OBJ_DECRYPTION) $(OBJ_ASM_AES) $(OBJ_ASM_AES_DECRYPT) $(OBJ_DECRYPTION)
	ld -o $(BINARY_DECRYPT) $(OBJ_DECRYPTION) $(OBJ_ASM_AES) $(OBJ_ASM_AES_DECRYPT)
	@echo "$(BINARY_DECRYPT) OK"

clean :
	make -C $(LIBFT_PATH) clean
	rm -Rf obj
	@echo "$(NAME_WOODY) and $(BINARY_DECRYPT) obj Deleted"

fclean : clean
	make -C $(LIBFT_PATH) fclean
	rm -f $(NAME_WOODY) $(BINARY_DECRYPT) woody
	@echo "$(NAME_WOODY) and $(BINARY_DECRYPT) Deleted"

re_WOODY : fclean test

re : fclean all

.PHONY : all obj clean fclean re
