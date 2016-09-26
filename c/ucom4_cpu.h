/************************
 *
 * ASTRO WARS EMULATOR
 * 
 * Should evolve to multi ucom4 / VFD EMU
 *
 * (c) 2016 MikeDX
 * 
 *************************/

#ifndef _UCOM4_CPU_H_
#define _UCOM4_CPU_H_

#include <stdint.h>

#define STACK_SIZE 3
#define BIT(x,n) (((x)>>(n))&1)

#define BITSWAP16(val,B15,B14,B13,B12,B11,B10,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0) \
                ((BIT(val,B15) << 15) | \
                        (BIT(val,B14) << 14) | \
                        (BIT(val,B13) << 13) | \
                        (BIT(val,B12) << 12) | \
                        (BIT(val,B11) << 11) | \
                        (BIT(val,B10) << 10) | \
                        (BIT(val, B9) <<  9) | \
                        (BIT(val, B8) <<  8) | \
                        (BIT(val, B7) <<  7) | \
                        (BIT(val, B6) <<  6) | \
                        (BIT(val, B5) <<  5) | \
                        (BIT(val, B4) <<  4) | \
                        (BIT(val, B3) <<  3) | \
                        (BIT(val, B2) <<  2) | \
                        (BIT(val, B1) <<  1) | \
                        (BIT(val, B0) <<  0))


enum
{
	NEC_UCOM4_PORTA = 0,
	NEC_UCOM4_PORTB,
	NEC_UCOM4_PORTC,
	NEC_UCOM4_PORTD,
	NEC_UCOM4_PORTE,
	NEC_UCOM4_PORTF,
	NEC_UCOM4_PORTG,
	NEC_UCOM4_PORTH,
	NEC_UCOM4_PORTI
};

enum
{
	NEC_UCOM43 = 0,
	NEC_UCOM44,
	NEC_UCOM45
};

typedef struct _ucom4cpu {

	uint16_t pc;
	uint16_t prev_pc;
	uint8_t op;
	uint8_t prev_op;
	uint8_t skip;
	uint8_t arg;
	uint8_t acc;
	uint16_t stack[STACK_SIZE];
	uint8_t port_out[0x10];
	uint8_t port_out_buf[0x10];
	int tc;
	uint8_t timer_f;
	uint8_t dpl;
	uint8_t dph;
	uint8_t carry_f;
	uint8_t carry_s_f;
	uint8_t int_f;
	uint8_t inte_f;
	int32_t int_line;
	uint8_t rom[0x800];
	uint8_t ram[0x80];
	uint8_t datamask;
	uint8_t bitmask;
	uint16_t prgmask;
	uint16_t stack_levels;
	uint8_t family;
	int icount;
	int old_icount;
	uint8_t inp_mux ;

	uint16_t grid;
	uint16_t plate;

	int display_wait;                 // led/lamp off-delay in microseconds (default 33ms)
	int display_maxy;                 // display matrix number of rows
	int display_maxx;                 // display matrix number of columns (max 31 for now)

	uint32_t display_state[0x20];       // display matrix rows data (last bit is used for always-on)
	uint16_t display_segmask[0x20];     // if not 0, display matrix row is a digit, mask indicates connected segments
	uint32_t display_cache[0x20];       // (internal use)
	uint32_t display_decay[0x20][0x20];  // (internal use)
	int decay_ticks;
	uint8_t audio_level;
	int sound_ticks;
	int totalticks;
	int aindex;
	int audio_avail;
	int cpu_rate;
	int sample_count;
	int sound_frequency;
} ucom4cpu;

void ucom4_reset(ucom4cpu *cpu);
int32_t ucom4_exec(ucom4cpu *cpu, int32_t ticks);
void ucom4_display_decay(ucom4cpu *cpu);
void ucom4_display_update(ucom4cpu *cpu);
void ucom4_display_matrix(ucom4cpu *cpu, int maxx, int maxy, int setx, int sety);

#endif
