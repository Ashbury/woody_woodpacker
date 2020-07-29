#include "aes.h"
#include "libft.h"

void	encrypt_text_section(uint8_t *buff, size_t size, uint8_t *key)
{
	uint8_t	extend_key[240];
	uint8_t	sbox[256];

	ft_memcpy(extend_key, key, 32);
	_generate_extend_key(extend_key, sbox);
	for (size_t i = 0; i + 16 <= size; i += 16)
		_encryption(extend_key, buff + i, sbox);
}
