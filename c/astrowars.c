#include <SDL.h>
#include "driver.h"
#include "vfd_emu.h"
#include "astrowars.h"

#include "lib/SDL_rotozoom.h"

vfd_game game_astrowars = { 
	.prepare_display = astrowars_prepare_display,
	.rom = "astrowars.rom",
	.romsize = 0x800,
	.setup_gfx = astrowars_setup_gfx,
	.close_gfx = astrowars_close_gfx,
	.display_update = astrowars_display_update,
	.input_r = astrowars_input_r,
	.output_w = astrowars_output_w,
	.name = "astrowars"
};

SDL_Surface *gfx[10][15];
SDL_Surface *bg,*bezel,*vfd_display, *tmpscreen;

int gfx_x[10][15];
int gfx_y[10][15];

void astrowars_close_gfx(void) {
	int x,y;

	for(x=0;x<15;x++) {
		for(y=0;y<10;y++) {
			if(gfx[x][y]) {
				SDL_FreeSurface(gfx[x][y]);
				gfx[x][y]=NULL;
			}
		}
	}
	SDL_FreeSurface(bg);
	SDL_FreeSurface(bezel);
	SDL_FreeSurface(vfd_display);
	SDL_FreeSurface(tmpscreen);
}

void astrowars_setup_gfx(void) {
	int x = 0;
	int y = 0;
	char filename[255];
	
	IMG_Init(IMG_INIT_PNG);
	SDL_Rect rect;
	memset(gfx_x,0,sizeof(gfx_x));
	memset(gfx_y,0,sizeof(gfx_y));

	bg=IMG_Load("res/gfx/astrowars/bg3.png");		

	bezel=IMG_Load("res/gfx/astrowars/bezel.png");

	tmpscreen=IMG_Load("res/gfx/astrowars/bezel.png");

	screen = SDL_SetVideoMode(bezel->w,bezel->h,32,SDL_HWSURFACE);

	vfd_display=IMG_Load("res/gfx/astrowars/bg3.png");

	// GRID 0
	// fig8 digit 1
	gfx_x[0][0]  =  79;    gfx_y[0][0]  =  1;
 	gfx_x[0][1]  =  58;    gfx_y[0][1]  =  0;
 	gfx_x[0][2]  =  55;    gfx_y[0][2]  =  1;
 	gfx_x[0][3]  =  62;    gfx_y[0][3]  =  19;
 	gfx_x[0][4]  =  55;    gfx_y[0][4]  =  25;
 	gfx_x[0][5]  =  0;     gfx_y[0][5]  =  0; // NOT USED
 	gfx_x[0][6]  =  79;    gfx_y[0][6]  =  24;
 	gfx_x[0][7]  =  59;    gfx_y[0][7]  =  43;
    
   	// fig8 digit 0    
   	gfx_x[0][8]  =  12;    gfx_y[0][8]  =  0;
 	gfx_x[0][9]  =  9;     gfx_y[0][9]  =  25;
 	gfx_x[0][10] =  9;     gfx_y[0][10] =  1;
 	gfx_x[0][11] =  33;    gfx_y[0][11] =  1;
 	gfx_x[0][12] =  16;    gfx_y[0][12] =  19;
 	gfx_x[0][13] =  33;    gfx_y[0][13] =  24; 
 	gfx_x[0][14] =  13;    gfx_y[0][14] =  43;
	 
	// GRID 1
	// fig8 digits 2 and 3
	for(x=0;x<15;x++) {
		gfx_x[1][x] = gfx_x[0][x]+(182-79);
		gfx_y[1][x] = gfx_y[0][x];
	}
	
	// GRID 2
	gfx_x[2][0]  =  132;   gfx_y[2][0]  = 129; 
	gfx_x[2][1]  =  169;   gfx_y[2][1]  = 129;
	gfx_x[2][2]  =  7;     gfx_y[2][2]  = 141;
	gfx_x[2][3]  =  8;     gfx_y[2][3]  = 97;
	gfx_x[2][4]  =  20;    gfx_y[2][4]  = 129;
	gfx_x[2][5]  =  43;    gfx_y[2][5]  = 140;
	gfx_x[2][6]  =  94;    gfx_y[2][6]  = 129;
	gfx_x[2][7]  =  58;    gfx_y[2][7]  = 129;

	gfx_x[2][8]  =  157;   gfx_y[2][8]  = 97;
	gfx_x[2][9]  =  155;   gfx_y[2][9]  = 141;
	gfx_x[2][10] =  118;   gfx_y[2][10] = 140;
	gfx_x[2][11] =  120;   gfx_y[2][11] = 97;
	gfx_x[2][12] =  81;    gfx_y[2][12] = 141;
	gfx_x[2][13] =  83;    gfx_y[2][13] = 97;
	gfx_x[2][14] =  46;    gfx_y[2][14] = 97;
	

	// GRID 3
	
	gfx_x[3][0]  =  130;   gfx_y[3][0]  = 241; 
	gfx_x[3][1]  =  168;   gfx_y[3][1]  = 241;
	gfx_x[3][2]  =  6;     gfx_y[3][2]  = 207;
	gfx_x[3][3]  =  20;    gfx_y[3][3]  = 193;
	gfx_x[3][4]  =  20;    gfx_y[3][4]  = 241;
	gfx_x[3][5]  =  44;    gfx_y[3][5]  = 207;
	gfx_x[3][6]  =  94;    gfx_y[3][6]  = 241;
	gfx_x[3][7]  =  56;    gfx_y[3][7]  = 241;

	gfx_x[3][8]  =  168;   gfx_y[3][8]  = 193;
	gfx_x[3][9]  =  154;   gfx_y[3][9]  = 207;
	gfx_x[3][10] =  118;   gfx_y[3][10] = 207;
	gfx_x[3][11] =  131;   gfx_y[3][11] = 193;
	gfx_x[3][12] =  80;    gfx_y[3][12] = 207;
	gfx_x[3][13] =  94;    gfx_y[3][13] = 193;
	gfx_x[3][14] =  57;    gfx_y[3][14] = 193;


	// GRID 4
	
	gfx_x[4][0]  =  130;   gfx_y[4][0]  = 310; 
	gfx_x[4][1]  =  168;   gfx_y[4][1]  = 310;
	gfx_x[4][2]  =  12;    gfx_y[4][2]  = 273;
	gfx_x[4][3]  =  2;     gfx_y[4][3]  = 273;
	gfx_x[4][4]  =  19;    gfx_y[4][4]  = 309;
	gfx_x[4][5]  =  51;    gfx_y[4][5]  = 273;
	gfx_x[4][6]  =  93;    gfx_y[4][6]  = 310;
	gfx_x[4][7]  =  56;    gfx_y[4][7]  = 309;

	gfx_x[4][8]  =  152;   gfx_y[4][8]  = 273;
	gfx_x[4][9]  =  160;   gfx_y[4][9]  = 274;
	gfx_x[4][10] =  124;   gfx_y[4][10] = 273;
	gfx_x[4][11] =  117;   gfx_y[4][11] = 274;
	gfx_x[4][12] =  89;    gfx_y[4][12] = 273;
	gfx_x[4][13] =  78;    gfx_y[4][13] = 274;
	gfx_x[4][14] =  41;    gfx_y[4][14] = 273;


	// GRID 5 - 8 repeated

	for(x=0;x<15;x++) {
		gfx_x[5][x] = gfx_x[4][x];
		gfx_y[5][x] = gfx_y[4][x]+(342-273);
	}

	for(x=0;x<15;x++) {
		gfx_x[6][x] = gfx_x[4][x];
		gfx_y[6][x] = gfx_y[4][x]+(413-273);
	}

	for(x=0;x<15;x++) {
		gfx_x[7][x] = gfx_x[4][x];
		gfx_y[7][x] = gfx_y[4][x]+(482-273);
	}
	for(x=0;x<15;x++) {
		gfx_x[8][x] = gfx_x[4][x];
		gfx_y[8][x] = gfx_y[4][x]+(554-273);
	}
		
	// GRID 9
	
	gfx_x[9][0]  =  115;   gfx_y[9][0]  = 655; 
	gfx_x[9][1]  =  152;   gfx_y[9][1]  = 655;
	gfx_x[9][2]  =  12;    gfx_y[9][2]  = 625;
	gfx_x[9][3]  =  3;     gfx_y[9][3]  = 625;
	gfx_x[9][4]  =  4;     gfx_y[9][4]  = 655;
	gfx_x[9][5]  =  48;    gfx_y[9][5]  = 625;
	gfx_x[9][6]  =  78;    gfx_y[9][6]  = 655;
	gfx_x[9][7]  =  41;    gfx_y[9][7]  = 655;

	gfx_x[9][8]  =  151;   gfx_y[9][8]  = 625;
	gfx_x[9][9]  =  160;   gfx_y[9][9]  = 625;
	gfx_x[9][10] =  123;   gfx_y[9][10] = 625;
	gfx_x[9][11] =  114;   gfx_y[9][11] = 625;
	gfx_x[9][12] =  86;    gfx_y[9][12] = 625;
	gfx_x[9][13] =  77;    gfx_y[9][13] = 625;
	gfx_x[9][14] =  40;    gfx_y[9][14] = 625;


	
	for(x=0;x<15;x++) {
		for(y=0;y<10;y++) {
			sprintf(filename,"res/gfx/astrowars/%d.%d.png",y,x);
			gfx[y][x]=IMG_Load(filename);		
			if(gfx[y][x]) {
				rect.x=gfx_x[y][x];
				rect.y=gfx_y[y][x];
				rect.w=gfx[y][x]->w;
				rect.h=gfx[y][x]->h;
				SDL_BlitSurface(gfx[y][x],NULL, vfd_display,&rect);
			}	
		}
	}
	
	SDL_BlitSurface(vfd_display, NULL, screen, NULL);

	SDL_Flip(screen);
}

void astrowars_display_update(void) {
	int x,y;
	SDL_Rect rect;

	SDL_Surface *tmp;


//	SDL_BlitSurface(bg, NULL, tmpscreen, NULL);
	SDL_FillRect(tmpscreen, NULL, SDL_MapRGB(tmpscreen->format, 0,0,0));
	
//	SDL_LockSurface( vfd_display );

	SDL_FillRect(vfd_display, NULL, SDL_MapRGB(vfd_display->format, 0,0,0));
	
	for(x=0;x<15;x++) {
		for(y=0;y<10;y++) {
			if(gfx[y][x] && (active_game->cpu->display_cache[y]&1<<x)) {
				rect.x=gfx_x[y][x];
				rect.y=gfx_y[y][x];
				rect.w=gfx[y][x]->w;
				rect.h=gfx[y][x]->h;
				SDL_BlitSurface(gfx[y][x],NULL, vfd_display,&rect);
			}	

		}
	}

//	SDL_UnlockSurface( vfd_display );

//	SDL_LockSurface( screen );


	rect.x=192;
	rect.y=84;
	rect.w=274-182;
	rect.h=362-84;

	tmp = rotozoomSurface(vfd_display, 0, .35,1);//rect.w/vfd_display->w,1);

	SDL_BlitSurface(tmp, NULL, tmpscreen, &rect);

	SDL_FreeSurface(tmp);

	SDL_BlitSurface(bezel, NULL, tmpscreen, NULL);

	SDL_BlitSurface(tmpscreen, NULL, screen, NULL);

//	SDL_UnlockSurface( screen );

	SDL_Flip(screen);
	SDL_PauseAudio(0);

}
void astrowars_prepare_display(ucom4cpu *cpu) {
	uint16_t grid = BITSWAP16(cpu->grid,15,14,13,12,11,10,0,1,2,3,4,5,6,7,8,9);
	uint16_t plate = BITSWAP16(cpu->plate,15,3,2,6,1,5,4,0,11,10,7,12,14,13,8,9);

	ucom4_display_matrix(cpu, 15, 10, plate, grid);

}

void astrowars_output_w(ucom4cpu *cpu, int index, uint8_t data)
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

uint8_t astrowars_input_r(ucom4cpu *cpu, int index)
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


