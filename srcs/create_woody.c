#include "woody_woodpacker.h"

static void	get_random_key(uint8_t key[KEY_SIZE])
{
	int	fd;
	int	size;

	if ((fd = open("/dev/urandom", O_RDONLY)) < 0)
	{
		ft_memset((void*)key, 0xbb, KEY_SIZE);
		ft_printf("Open /dev/urandom fail\n");
		return ;
	}
	size = read(fd, key, KEY_SIZE);
	if (size < KEY_SIZE)
	{
		ft_memset((void*)key, 0xbb, KEY_SIZE);
		ft_printf("Read /dev/urandom fail %d\n", size);
		return ;
	}
	*(size_t*)(unpacking_section + FIRST_KEY_PART_IDX) = *(size_t*)(key);
	*(size_t*)(unpacking_section + SECOND_KEY_PART_IDX) = *(size_t*)(key + 8);
	*(size_t*)(unpacking_section + THIRD_KEY_PART_IDX) = *(size_t*)(key + 16);
	*(size_t*)(unpacking_section + FOURTH_KEY_PART_IDX) = *(size_t*)(key + 24);
	ft_printf("key: ");
	for (int i = 0; i < KEY_SIZE; i++)
		ft_printf("%02x", key[i]);
	ft_printf("\n");
}

/*
** No need to check the addresses here since they all got checked during parsing.
*/
static void	shift_section_headers(t_woody_data *data)
{
	size_t		i;
	Elf64_Shdr	tmp;

	i = 0;
	while (i < data->file_header->e_shnum &&
				&(data->first_section_header[i]) != data->bss_section_header)
		i++;
	while (++i < data->file_header->e_shnum - 1)
	{
		ft_memcpy(&tmp, &(data->first_section_header[i]), sizeof(Elf64_Shdr));
		ft_memcpy(&(data->first_section_header[i]), &(data->new_section_header), sizeof(Elf64_Shdr));
		ft_memcpy(&(data->new_section_header), &tmp, sizeof(Elf64_Shdr));
	}
	data->file_header->e_shstrndx += 1;
}

static void	write_woody(t_woody_data *data, char *file)
{
	int		fd;
	size_t	i;
	char	padding_string[PADDING_SIZE];

	ft_bzero(padding_string, PADDING_SIZE);
	fd = open("woody", O_WRONLY | O_CREAT | O_TRUNC, 0755);
	if (fd == -1)
		perror("Open: ");
	write(fd, file, data->old_end_wload);
	for (i = 0; i + PADDING_SIZE <= data->adjustement; i += PADDING_SIZE)
		write(fd, padding_string, PADDING_SIZE);
	write(fd, padding_string, data->adjustement - i);
	write(fd, unpacking_section, sizeof(unpacking_section));
	write(fd, padding_string, data->align_after_new_section);
	write(fd, file + data->old_end_wload, data->file_len - data->old_end_wload);

	/* Since we shifted section headers, this is now the last header of the file. */
	write(fd, &data->new_section_header, sizeof(Elf64_Shdr));
}

void	create_woody(t_woody_data *data)
{
	char	*file;
	uint8_t	*ptr_text_section;
	size_t	size_text_sextion;
	uint8_t	key[KEY_SIZE];

	data->file_header->e_shoff += sizeof(unpacking_section) + data->adjustement
			+ data->align_after_new_section;
	shift_section_headers(data);
	file = malloc(data->file_len);
	ft_memcpy(file, data->file, data->file_len);
	get_random_key(key);
	ptr_text_section = (uint8_t*)((size_t)file + (size_t)data->text_section_header->sh_offset);
	size_text_sextion = data->text_section_header->sh_size;
	munmap(data->file, data->file_len);
	encrypt_text_section(ptr_text_section, size_text_sextion, key);
	write_woody(data, file);
	free(file);
}