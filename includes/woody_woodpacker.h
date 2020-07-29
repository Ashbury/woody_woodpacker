#ifndef WOODY_WOODPACKER_H
# define WOODY_WOODPACKER_H

# include <stdlib.h>
# include <unistd.h>
# include <stdio.h>
# include <fcntl.h>
# include <sys/types.h>
# include <sys/stat.h>
# include <sys/mman.h>
# include <elf.h>
# include "libft.h"

# define ELF_MAGIC 0x464c457f

# define UNPACKING_SECTION_SIZE 0x85c

# define OLD_ENTRY_POINT_IDX 28
# define NEW_SECTION_ADDR_IDX 38
# define TEXT_SECTION_ADDR_IDX 58
# define TEXT_SECTION_SIZE_IDX 188

# define PADDING_SIZE 128

# define KEY_SIZE 32
# define FIRST_KEY_PART_IDX 79
# define SECOND_KEY_PART_IDX 93
# define THIRD_KEY_PART_IDX 108
# define FOURTH_KEY_PART_IDX 123

typedef struct	s_woody_data
{
	size_t		entry_point;
	size_t		file_len;
	size_t		previous_segment_size;
	size_t		adjustement;
	size_t		align_after_new_section;
	size_t		old_end_wload;
	char		*file;
	void		*string_table;
	char		*text_section_begin;
	char		*encoded_text_section;
	Elf64_Ehdr	*file_header;
	Elf64_Phdr	*first_program_header;
	Elf64_Phdr	*loadx_program_header;
	Elf64_Phdr	*loadw_program_header;
	Elf64_Shdr	*first_section_header;
	Elf64_Shdr	*text_section_header;
	Elf64_Shdr	*bss_section_header;
	Elf64_Shdr	new_section_header;
}				t_woody_data;

extern char unpacking_section[UNPACKING_SECTION_SIZE];

void	create_woody(t_woody_data *data);
void	encrypt_text_section(uint8_t *buff, size_t size, uint8_t *key);
int		parse_file(t_woody_data *data);

#endif