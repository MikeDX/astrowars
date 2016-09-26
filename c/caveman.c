#include <SDL.h>
#include "driver.h"
#include "vfd_emu.h"
#include "caveman.h"

vfd_game game_caveman = { 
	.prepare_display = caveman_prepare_display,
	.rom = "caveman.rom",
	.romsize = 0x800,
	.setup_gfx = caveman_setup_gfx,
	.display_update = caveman_display_update,
	.input_r = caveman_input_r,
	.output_w = caveman_output_w,
	.name = "caveman"
};

SDL_Surface *gfx[10][15];
SDL_Surface *bg;

int gfx_x[10][15];
int gfx_y[10][15];

void caveman_setup_gfx(void) {
	int x = 0;
	int y = 0;
	char filename[255];
	
	IMG_Init(IMG_INIT_PNG);
	
	screen = SDL_SetVideoMode(684,193,32,SDL_HWSURFACE);

}

void caveman_display_update(void) {
	int x,y;
	SDL_Rect rect;

	SDL_Flip(screen);
	SDL_PauseAudio(0);

}
void caveman_prepare_display(ucom4cpu *cpu) {
	uint16_t grid = BITSWAP16(cpu->grid,15,14,13,12,11,10,0,1,2,3,4,5,6,7,8,9);
	uint16_t plate = BITSWAP16(cpu->plate,15,3,2,6,1,5,4,0,11,10,7,12,14,13,8,9);

	ucom4_display_matrix(cpu, 15, 10, plate, grid);

}

void caveman_output_w(ucom4cpu *cpu, int index, uint8_t data)
{
	index &= 0xf;
	data &= 0xf;

	int shift;

	if(index == NEC_UCOM4_PORTI)
		data &=0x7;
	
	switch (index) {
		case NEC_UCOM4_PORTC:
		case NEC_UCOM4_PORTD:
		case NEC_UCOM4_PORTE:
			// E3: speaker out
			if (index == NEC_UCOM4_PORTE)
				level_w(cpu, data >> 3 & 1);

			// C,D,E01: vfd matrix grid
			shift = (index - NEC_UCOM4_PORTC) * 4;
			cpu->grid = (cpu->grid & ~(0xf << shift)) | (data << shift);
			active_game->prepare_display(cpu);
			break;

		case NEC_UCOM4_PORTF:
		case NEC_UCOM4_PORTG:
		case NEC_UCOM4_PORTH:
		case NEC_UCOM4_PORTI:
			shift = (index - NEC_UCOM4_PORTF) * 4;
			cpu->plate = (cpu->plate & ~(0xf << shift)) | (data << shift);
			active_game->prepare_display(cpu);
			break;
		default:
			printf("Write to unknown port: %d\n",index);
			break;

	}
	cpu->port_out[index] = data;
}

uint8_t caveman_input_r(ucom4cpu *cpu, int index)
{
	index &= 0xf;
	uint8_t inp = 0;

	switch (index)
	{
		case NEC_UCOM4_PORTA:
			inp = inputs[2]<<2|inputs[1]<<1|inputs[0];

			break;
		case NEC_UCOM4_PORTB:
			inp = inputs[4]<<1|inputs[3];
			break;
	}
	return inp & 0xf;
}


