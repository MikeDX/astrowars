#include <SDL.h>
#include "driver.h"
#include "vfd_emu.h"
#include "caveman.h"

vfd_game game_caveman = { 
	.prepare_display = caveman_prepare_display,
	.rom = "caveman.rom",
	.romsize = 0x800,
	.setup_gfx = caveman_setup_gfx,
	.close_gfx = caveman_close_gfx,
	.display_update = caveman_display_update,
	.input_r = caveman_input_r,
	.output_w = caveman_output_w,
	.name = "caveman"
};

SDL_Surface *gfx[20][20];
SDL_Surface *bg;

int gfx_x[20][20];
int gfx_y[20][20];

void caveman_close_gfx(void) {
	int x,y;

	for(y=0;y<19;y++) {
		for(x=0;x<10;x++) {
			if(gfx[x][y]) {
				SDL_FreeSurface(gfx[x][y]);
				gfx[x][y]=NULL;
			}
		}
	}
	SDL_FreeSurface(bg);
}

void caveman_setup_gfx(void) {
	int x = 0;
	int y = 0;
	char filename[255];
	SDL_Rect rect;

	char hd[4]="hd/";
	
	IMG_Init(IMG_INIT_PNG);
	memset(gfx_x,0,sizeof(gfx_x));
	memset(gfx_y,0,sizeof(gfx_y));



	if(0) {
// GFX
	screen = SDL_SetVideoMode(684,199,32,SDL_HWSURFACE);

	gfx_x[0][0]=27;		gfx_y[0][0]=8;
	gfx_x[0][1]=53;		gfx_y[0][1]=47;
	gfx_x[0][2]=50;		gfx_y[0][2]=31;
	gfx_x[0][3]=68;		gfx_y[0][3]=31;
	gfx_x[0][4]=55;		gfx_y[0][4]=26;
	gfx_x[0][5]=50;		gfx_y[0][5]=9;
	
	gfx_x[0][6]=19;		gfx_y[0][6]=107; // CAVE
	
	gfx_x[0][7]=69;		gfx_y[0][7]=9;
	gfx_x[0][8]=53;		gfx_y[0][8]=5;


	// EGGS
	gfx_x[0][9]=43;		gfx_y[0][9]=169;
	gfx_x[0][10]=60;	gfx_y[0][10]=170;
	gfx_x[0][11]=26;	gfx_y[0][11]=169;

	gfx_x[0][12]=25;	gfx_y[0][12]=150;
	gfx_x[0][13]=43;	gfx_y[0][13]=149;
	gfx_x[0][14]=60;	gfx_y[0][14]=149;

	gfx_x[0][15]=33;	gfx_y[0][15]=132;
	gfx_x[0][16]=53;	gfx_y[0][16]=132;

	// PTERODACTYLS
	gfx_x[0][17]=17;	gfx_y[0][17]=84;
	gfx_x[0][18]=20;	gfx_y[0][18]=57;

	// GRID 1
	gfx_x[1][0]=137;	gfx_y[1][0]=5;
	gfx_x[1][1]=98;		gfx_y[1][1]=47;
	gfx_x[1][2]=95;		gfx_y[1][2]=31;
	gfx_x[1][3]=114;	gfx_y[1][3]=31;
	gfx_x[1][4]=101;	gfx_y[1][4]=26;
	gfx_x[1][5]=95;		gfx_y[1][5]=8;

	// TABLE
	gfx_x[1][6]=96;		gfx_y[1][6]=179;

	gfx_x[1][7]=114;	gfx_y[1][7]=8;
	gfx_x[1][8]=99;		gfx_y[1][8]=5;
	

	// BODY 1
	gfx_x[1][9]=123;	gfx_y[1][9]=138;
	
	// EGG
	gfx_x[1][10]=96;	gfx_y[1][10]=156;

	// MUD?
	gfx_x[1][11]=115;	gfx_y[1][11]=177;

	gfx_x[1][12]=115;	gfx_y[1][12]=145;
	gfx_x[1][13]=130;	gfx_y[1][13]=130;
	gfx_x[1][14]=153;	gfx_y[1][14]=99;
	gfx_x[1][15]=151;	gfx_y[1][15]=74;
	gfx_x[1][16]=155;	gfx_y[1][16]=57;
	gfx_x[1][17]=97;	gfx_y[1][17]=89;
	gfx_x[1][18]=106;	gfx_y[1][18]=53;


	// GRID 2

	// NO 0
	// MUD

	gfx_x[2][1]=219;	gfx_y[2][1]=6;
	
	// AXE
	gfx_x[2][2]=182; 	gfx_y[2][2]=23;
	gfx_x[2][3]=218;	gfx_y[2][3]=60;
	gfx_x[2][4]=182;	gfx_y[2][4]=80;
	gfx_x[2][5]=213;	gfx_y[2][5]=95;

	// NO 6

	// HEAD UP
	gfx_x[2][7]=199;	gfx_y[2][7]=112;

	// BODY
	gfx_x[2][8]=184;		gfx_y[2][8]=139;

	// HEAD DOWN
	gfx_x[2][9]=183;	gfx_y[2][9]=172;

	// EGG
	gfx_x[2][10]=182;	gfx_y[2][10]=151;

	// MUD
	gfx_x[2][11]=220;	gfx_y[2][11]=153;

	// AXE
	gfx_x[2][12]=182;	gfx_y[2][12]=108;

	// MUD
	gfx_x[2][13]=198;	gfx_y[2][13]=103;
	gfx_x[2][14]=200;	gfx_y[2][14]=85;
	gfx_x[2][15]=192;	gfx_y[2][15]=72;
	gfx_x[2][16]=182;	gfx_y[2][16]=46;

	// PTERODACTYLS
	gfx_x[2][17]=182;	gfx_y[2][17]=43;
	gfx_x[2][18]=190;	gfx_y[2][18]=6;





	// GRID 3

	// NO 0
	// MUD

	gfx_x[3][1]=287;	gfx_y[3][1]=14;
	
	// AXE
	gfx_x[3][2]=249; 	gfx_y[3][2]=27;
	gfx_x[3][3]=282;	gfx_y[3][3]=61;
	gfx_x[3][4]=250;	gfx_y[3][4]=77;
	gfx_x[3][5]=281;	gfx_y[3][5]=94;

	// NO 6

	// HEAD UP
	gfx_x[3][7]=266;	gfx_y[3][7]=114;

	// BODY
	gfx_x[3][8]=251;	gfx_y[3][8]=138;

	// HEAD DOWN
	gfx_x[3][9]=249;	gfx_y[3][9]=169;

	// EGG
	gfx_x[3][10]=282;	gfx_y[3][10]=159;

	// MUD
	gfx_x[3][11]=253;	gfx_y[3][11]=148;

	// AXE
	gfx_x[3][12]=249;	gfx_y[3][12]=108;

	// MUD
	gfx_x[3][13]=265;	gfx_y[3][13]=106;
	gfx_x[3][14]=268;	gfx_y[3][14]=82;
	gfx_x[3][15]=266;	gfx_y[3][15]=65;
	gfx_x[3][16]=267;	gfx_y[3][16]=28;

	// PTERODACTYLS
	gfx_x[3][17]=252;	gfx_y[3][17]=35;
	gfx_x[3][18]=249;	gfx_y[3][18]=6;


	// GRID 4

	// NO 0
	// MUD

	gfx_x[4][1]=357;	gfx_y[4][1]=15;
	
	// AXE
	gfx_x[4][5]=348;	gfx_y[4][5]=93;

	// NO 6

	// HEAD UP
	gfx_x[4][7]=332;	gfx_y[4][7]=113;

	// BODY
	gfx_x[4][8]=317;	gfx_y[4][8]=140;

	// HEAD DOWN
	gfx_x[4][9]=317;	gfx_y[4][9]=171;

	// EGG
	gfx_x[4][10]=316;	gfx_y[4][10]=153;

	// MUD
	gfx_x[4][11]=353;	gfx_y[4][11]=153;

	// AXE
	gfx_x[4][12]=316;	gfx_y[4][12]=107;

	// MUD
	gfx_x[4][13]=332;	gfx_y[4][13]=103;
	gfx_x[4][14]=325;	gfx_y[4][14]=79;
	gfx_x[4][15]=338;	gfx_y[4][15]=63;
	gfx_x[4][16]=336;	gfx_y[4][16]=28;

	// PTERODACTYLS
	gfx_x[4][17]=318;	gfx_y[4][17]=36;
	gfx_x[4][18]=317;	gfx_y[4][18]=6;



	// GRID 5

	// NO 0
	// MUD

	gfx_x[5][1]=425;	gfx_y[5][1]=15;
	
	// AXE
	gfx_x[5][3]=418;	gfx_y[5][3]=59;
	gfx_x[5][4]=385;	gfx_y[5][4]=76;
	gfx_x[5][5]=413;	gfx_y[5][5]=91;

	// NO 6

	// HEAD UP
	gfx_x[5][7]=401;	gfx_y[5][7]=114;

	// BODY
	gfx_x[5][8]=383;	gfx_y[5][8]=139;

	// HEAD DOWN
	gfx_x[5][9]=383;	gfx_y[5][9]=170;

	// EGG
	gfx_x[5][10]=416;	gfx_y[5][10]=159;

	// MUD
	gfx_x[5][11]=390;	gfx_y[5][11]=150;

	// AXE
	gfx_x[5][12]=384;	gfx_y[5][12]=107;

	// MUD
	gfx_x[5][13]=401;	gfx_y[5][13]=103;
	gfx_x[5][14]=403;	gfx_y[5][14]=81;
	gfx_x[5][15]=400;	gfx_y[5][15]=63;
	gfx_x[5][16]=405;	gfx_y[5][16]=29;

	// PTERODACTYLS
	gfx_x[5][17]=385;	gfx_y[5][17]=36;
	gfx_x[5][18]=384;	gfx_y[5][18]=6;


	// GRID 6
	// ROCKS
	gfx_x[6][1]=452;	gfx_y[6][1]=6;

	// AXE
	gfx_x[6][2]=454;	gfx_y[6][2]=33;
	gfx_x[6][3]=452;	gfx_y[6][3]=66;

	// DINO BODY
	gfx_x[6][6]=486;	gfx_y[6][6]=67;

	// CAVEMAN
	gfx_x[6][8]=452;	gfx_y[6][8]=140;

	// EGGS
	gfx_x[6][9]=567;	gfx_y[6][9]=175;
	gfx_x[6][10]=521;	gfx_y[6][10]=175;
	gfx_x[6][11]=478;	gfx_y[6][11]=175;

	// DINO HEAD RIGHT
	gfx_x[6][12]=534;	gfx_y[6][12]=50;

	// DINO HEAD LEFT + FIRE
	gfx_x[6][13]=451;	gfx_y[6][13]=56;

	// DINO NECK PART
	gfx_x[6][14]=507;	gfx_y[6][14]=62;

	// HIT
	gfx_x[6][15]=461;	gfx_y[6][15]=47;

	// DINO SEES STARS
	gfx_x[6][16]=529;	gfx_y[6][16]=22;

	// DIN HEAD UP
	gfx_x[6][17]=471;	gfx_y[6][17]=7;


	// GRID 7
	// VOLACO EXPLOSION
	gfx_x[7][1]=591;	gfx_y[7][1]=7;

	// VOLCANO
	gfx_x[7][6]=600;	gfx_y[7][6]=75;

	// BABY HATCHED
	gfx_x[7][10]=604;	gfx_y[7][10]=123;

	// BABY 2
	gfx_x[7][11]=630;	gfx_y[7][11]=144;

	// LAVA RUN
	gfx_x[7][13]=600;	gfx_y[7][13]=90;

	// VOLCANO ERRUPTIONS
	gfx_x[7][15]=608;	gfx_y[7][15]=62;
	gfx_x[7][16]=609;	gfx_y[7][16]=48;

	} else {
		screen = SDL_SetVideoMode(1000,300,32,SDL_HWSURFACE);

		int xoffs[]={8,110,220,319,418,517,616,820};

		for(x=0;x<19;x++) {
			for(y=0;y<10;y++) {
				gfx_x[y][x]=10+xoffs[y];
				gfx_y[y][x]=10;
			}
		}

	}

	sprintf(filename,"res/gfx/caveman/%svfd.png",hd);

	bg=IMG_Load(filename);

	for(x=0;x<19;x++) {
		for(y=0;y<10;y++) {
			sprintf(filename,"res/gfx/caveman/%s%d.%d.png",hd,y,x);
			gfx[y][x]=NULL;
			gfx[y][x]=IMG_Load(filename);
			if(gfx[y][x]) {
//				printf("%s \n",filename);
				rect.x=gfx_x[y][x];
				rect.y=gfx_y[y][x];
				rect.w=gfx[y][x]->w;
				rect.h=gfx[y][x]->h;
				SDL_BlitSurface(gfx[y][x],NULL, bg,&rect);
			} else {
//				printf("Failed: %s\n",filename);
			}	
		}
	}

	SDL_BlitSurface(bg,NULL, screen,NULL);

	SDL_Flip(screen);

	SDL_PauseAudio(0);

}

void caveman_display_update(void) {
	int x,y;
	SDL_Rect rect;

//	SDL_BlitSurface(bg, NULL, screen, NULL);
//	SDL_FillRect(bg, NULL, SDL_MapRGB(bg->format, 0,0,0));
	SDL_FillRect(screen, NULL, SDL_MapRGB(screen->format, 0,0,0));


	for(x=0;x<19;x++) {
		for(y=0;y<10;y++) {
			if(gfx[y][x] && (active_game->cpu->display_cache[y]&1<<x)) {
				rect.x=gfx_x[y][x];
				rect.y=gfx_y[y][x];
				rect.w=gfx[y][x]->w;
				rect.h=gfx[y][x]->h;
				SDL_BlitSurface(gfx[y][x],NULL, screen,&rect);
			}	

		}
	}
//	SDL_BlitSurface(bg,NULL, screen,NULL);

	SDL_Flip(screen);


}
void caveman_prepare_display(ucom4cpu *cpu) {
	uint8_t grid = BITSWAP8(cpu->grid,0,1,2,3,4,5,6,7);
	uint32_t plate = BITSWAP24(cpu->plate,23,22,21,20,19,10,11,5,6,7,8,0,9,2,18,17,16,3,15,14,13,12,4,1) | 0x40;
	ucom4_display_matrix(cpu, 19, 8, plate, grid);

}

void caveman_output_w(ucom4cpu *cpu, int index, uint8_t data)
{
	index &= 0xf;
	data &= 0xf;

	int shift;

	// if(index == NEC_UCOM4_PORTI)
	// 	data &=0x7;
	
	switch (index) {
		// C,D: vfd matrix grid
		case NEC_UCOM4_PORTC:
		case NEC_UCOM4_PORTD:
			shift = (index - NEC_UCOM4_PORTC) * 4;
			cpu->grid = (cpu->grid & ~(0xf << shift)) | (data << shift);
			active_game->prepare_display(cpu);
			break;

		case NEC_UCOM4_PORTE:
		case NEC_UCOM4_PORTF:
		case NEC_UCOM4_PORTG:
		case NEC_UCOM4_PORTH:
		case NEC_UCOM4_PORTI:
			// E3: speaker out
			if (index == NEC_UCOM4_PORTE)
				level_w(cpu, data >> 3 & 1);

			// E012,F,G,H,I: vfd matrix plate
			shift = (index - NEC_UCOM4_PORTE) * 4;
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
			inp = inputs[4]<<3|inputs[3]<<3|inputs[2]|inputs[1]<<1|inputs[0]<<2;
			break;
		// case NEC_UCOM4_PORTB:
		// 	inp = inputs[4]<<1|inputs[3];
		// 	break;
	}
	return inp;
}


