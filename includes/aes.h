#ifndef AES_H
# define AES_H

#include <inttypes.h>
#include <stdio.h>

void		_encryption(uint8_t extend_key[240], uint8_t *buff, uint8_t sbox[256]);
void		_generation_s_box(uint8_t sbox[256]);
uint32_t	_substitute_column(uint8_t sbox[256], uint8_t *column);
uint32_t	_rotate_column(uint32_t col);
void		*_generate_extend_key(uint8_t key[240], uint8_t sbox[256]);
uint32_t	_rcon_round(uint8_t rcount, uint32_t col);
void		_add_round_key(uint8_t *block, uint8_t *extend_key);
void		_subbyte_sbox(uint8_t *block, uint8_t *sbox);
void		_shift_rows(uint8_t *block);
void		_mix_column(uint8_t *block);
#endif