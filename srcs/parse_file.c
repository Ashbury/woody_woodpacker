#include "woody_woodpacker.h"

static int	check_elf(t_woody_data *data)
{
	unsigned int	magic_number;

	if (data->file_len < sizeof(Elf64_Ehdr) + 2 * sizeof(Elf64_Phdr)
			+ 2 * sizeof(Elf64_Shdr))
	{
		ft_dprintf(2, "This file is too short to be a proper elf.\n");
		return (0);
	}
	magic_number = *(unsigned int*)(data->file);
	if (magic_number != ELF_MAGIC)
	{
		ft_dprintf(2, "This file is not an elf\n");
		return (0);
	}
	data->file_header = (Elf64_Ehdr*)data->file;
	if (data->file_header->e_ident[EI_CLASS] != ELFCLASS64)
	{
		ft_dprintf(2, "This elf is not 64-bit\n");
		return (0);
	}
	return (1);
}

static int	is_addr_safe(t_woody_data *data, size_t value_size, void *addr)
{
	if ((size_t)(addr + value_size) > (size_t)(data->file + data->file_len)
			|| (size_t)addr <= (size_t)data->file)
	{
		ft_dprintf(2, "Corrupted file.\n");
		return (0);
	}
	return (1);
}

static int	get_load_segments(t_woody_data *data)
{
	size_t		i;
	size_t		found;
	Elf64_Phdr	*header;

	found = 0;
	i = 0;

	while (i < data->file_header->e_phnum)
	{
		header = (Elf64_Phdr *)((char *)data->first_program_header + sizeof(Elf64_Phdr) * i);
		if (!is_addr_safe(data, sizeof(Elf64_Phdr), header))
			return (0);
		if (header->p_type == PT_LOAD && header->p_flags & PF_X)
		{
			header->p_flags |= PF_W;
			data->loadx_program_header = header;
			i++;
			found++;
			break ;
		}
		i++;
	}
	while (i < data->file_header->e_phnum)
	{
		header = (Elf64_Phdr *)((char *)data->first_program_header + sizeof(Elf64_Phdr) * i);
		if (!is_addr_safe(data, sizeof(Elf64_Phdr), header))
			return (0);
		if (header->p_type == PT_LOAD && header->p_flags & PF_W)
		{
			header->p_flags |= PF_X;
			data->loadw_program_header = header;
			found++;
		}
		i++;
	}
	return (found == 2);
}

static int	find_section(t_woody_data *data, char *wanted_section, void **ptr)
{
	size_t		i;
	Elf64_Shdr	*header;
	char		*section_name;

	i = 0;
	while (i < data->file_header->e_shnum)
	{
		header = (Elf64_Shdr *)((char *)data->first_section_header + sizeof(Elf64_Shdr) * i);
		if (!is_addr_safe(data, sizeof(Elf64_Shdr), header))
			return (0);
		section_name = data->string_table + header->sh_name;
		if (!is_addr_safe(data, 64, section_name))
			return (0);
		if (!ft_memcmp(wanted_section, section_name, ft_strlen(wanted_section)))
		{
			*ptr = header;
			break;
		}
		i++;
	}
	return (*ptr != NULL);
}

static int	get_headers(t_woody_data *data)
{
	data->first_program_header = (Elf64_Phdr*)(data->file + sizeof(Elf64_Ehdr));
	if (!is_addr_safe(data, sizeof(Elf64_Phdr), data->first_program_header))
		return (0);
	if (get_load_segments(data) == 0)
	{
		ft_dprintf(2, "This elf doesn't have the two canonical loaded segment...\n");
		return (0);
	}
	ft_printf("loaded_segment beginning virtual addr: %#zx, loaded segment size: %zu\n",
			data->loadx_program_header->p_vaddr, data->loadx_program_header->p_memsz);

	/* GETTING AND REWRITING SECTIONS TO INJECT NEW ENTRY */
	data->first_section_header = (Elf64_Shdr*)(data->file + data->file_header->e_shoff);
	if (!is_addr_safe(data, sizeof(Elf64_Shdr), data->first_section_header))
		return (0);
	data->string_table = data->file + data->first_section_header[data->file_header->e_shstrndx].sh_offset;
	if (find_section(data, ".text", (void*)&data->text_section_header) == 0)
	{
		ft_dprintf(2, "It appears this elf has no .text section...\n");
		return (0);
	}
	if (find_section(data, ".bss", (void*)&data->bss_section_header) == 0)
	{
		ft_dprintf(2, "It appears this elf has no .bss section...\n");
		return (0);
	}
	return (1);
}

static Elf64_Shdr	*get_section_after_wload(t_woody_data *data)
{
	size_t		i;
	Elf64_Shdr	*header;

	i = 0;
	while (i < data->file_header->e_shnum)
	{
		header = (Elf64_Shdr *)((char *)data->first_section_header + i * sizeof(Elf64_Shdr));
		if (!is_addr_safe(data, sizeof(Elf64_Shdr), data->first_section_header))
			return (NULL);
		if (header->sh_offset >= data->loadw_program_header->p_offset + data->loadw_program_header->p_filesz
				&& !(header->sh_addr))
			return (header);
		i++;
	}
	return (NULL);
}

static size_t	get_largest_alignment(t_woody_data *data)
{
	size_t		i;
	size_t		max_align;
	Elf64_Shdr	*header;

	max_align = 0;
	i = 0;
	while (i < data->file_header->e_shnum)
	{
		header = (Elf64_Shdr *)((char *)data->first_section_header + i * sizeof(Elf64_Shdr));
		if (!is_addr_safe(data, sizeof(Elf64_Shdr), data->first_section_header))
			return (0);
		if (header->sh_offset >= data->loadw_program_header->p_offset + data->loadw_program_header->p_filesz)
			break ;
		i++;
	}
	while (i < data->file_header->e_shnum)
	{
		header = (Elf64_Shdr *)((char *)data->first_section_header + i * sizeof(Elf64_Shdr));
		if (!is_addr_safe(data, sizeof(Elf64_Shdr), data->first_section_header))
			return (0);
		if (header->sh_addralign > max_align)
			max_align = header->sh_addralign;
		i++;
	}
	return (max_align);
}

static size_t	make_new_section_header(t_woody_data *data)
{
	size_t		adjustement_new_section;
	size_t		mod_for_align_next_section;
	size_t		largest_alignment;
	Elf64_Shdr	*section_after_wload;

	section_after_wload = get_section_after_wload(data);
	if (section_after_wload == NULL)
		return (0);
	largest_alignment = get_largest_alignment(data);
	if (largest_alignment == 0)
		return (0);
	data->old_end_wload = data->loadw_program_header->p_offset + data->loadw_program_header->p_filesz;
	mod_for_align_next_section = section_after_wload->sh_offset % largest_alignment;
	data->new_section_header.sh_name = data->text_section_header->sh_name + 2;
	data->new_section_header.sh_type = SHT_PROGBITS;
	data->new_section_header.sh_flags = SHF_ALLOC + SHF_EXECINSTR;
	data->new_section_header.sh_offset = data->loadw_program_header->p_offset
			+ data->loadw_program_header->p_memsz;
	data->new_section_header.sh_addr = data->loadw_program_header->p_vaddr
			+ data->loadw_program_header->p_memsz;
	data->new_section_header.sh_size = sizeof(unpacking_section);
	data->new_section_header.sh_link = 0;
	data->new_section_header.sh_info = 0;
	data->new_section_header.sh_addralign = 64;
	data->new_section_header.sh_entsize = 0;
	adjustement_new_section = (data->new_section_header.sh_addralign
			- (data->new_section_header.sh_addr
			% data->new_section_header.sh_addralign)) % data->new_section_header.sh_addralign;
	data->new_section_header.sh_offset += adjustement_new_section;
	data->new_section_header.sh_addr += adjustement_new_section;
	data->align_after_new_section = (largest_alignment - ((data->new_section_header.sh_offset
			+ data->new_section_header.sh_size - mod_for_align_next_section)
			% largest_alignment)) % largest_alignment;
	data->loadw_program_header->p_filesz += data->align_after_new_section + sizeof(unpacking_section);
	data->loadw_program_header->p_memsz += data->align_after_new_section
			+ adjustement_new_section + sizeof(unpacking_section);
	data->adjustement = data->loadw_program_header->p_memsz - data->loadw_program_header->p_filesz;
	data->loadw_program_header->p_filesz = data->loadw_program_header->p_memsz;
	return (1);
}

static int		adapt_offset_after_bss(t_woody_data *data)
{
	size_t		i;
	Elf64_Shdr	*header;

	i = 0;
	while (i < data->file_header->e_shnum - 1)
	{
		header = (Elf64_Shdr *)((char *)data->first_section_header + i * sizeof(Elf64_Shdr));
		if (!is_addr_safe(data, sizeof(Elf64_Shdr), data->first_section_header))
			return (0);
		if (header == data->bss_section_header)
			break;
		i++;
	}
	while (++i < data->file_header->e_shnum - 1)
	{
		header = (Elf64_Shdr *)((char *)data->first_section_header + i * sizeof(Elf64_Shdr));
		if (!is_addr_safe(data, sizeof(Elf64_Shdr), data->first_section_header))
			return (0);
		header->sh_offset += sizeof(unpacking_section) + data->adjustement
				+ data->align_after_new_section;
	}
	return (1);
}

int			parse_file(t_woody_data *data)
{
	if (check_elf(data) == 0 || get_headers(data) == 0 || make_new_section_header(data) == 0)
		return (0);
	data->entry_point = data->file_header->e_entry;
	*(size_t*)(unpacking_section + OLD_ENTRY_POINT_IDX) = data->entry_point;
	*(size_t*)(unpacking_section + NEW_SECTION_ADDR_IDX) = data->new_section_header.sh_addr;
	*(size_t*)(unpacking_section + TEXT_SECTION_ADDR_IDX) = data->text_section_header->sh_offset + data->loadx_program_header->p_vaddr;
	*(size_t*)(unpacking_section + TEXT_SECTION_SIZE_IDX) = data->text_section_header->sh_size;
	data->file_header->e_entry = data->new_section_header.sh_addr;
	data->file_header->e_shnum += 1;
	if (adapt_offset_after_bss(data) == 0)
		return (0);
	return (1);
}