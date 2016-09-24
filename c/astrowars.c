/************************
 *
 * ASTRO WARS EMULATOR
 * 
 * Should evolve to multi ucom4 / VFD EMU
 *
 * (c) 2016 MikeDX
 * 
 *************************/
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>

#include "astrowars.h"

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

#ifdef HAS_SDL
#include <SDL.h>
#include <SDL_image.h>

SDL_Surface *screen;
int gfx_x[10][15];
int gfx_y[10][15];

SDL_Surface *gfx[10][15];

#endif

ucom4cpu cpu;

int load_rom(ucom4cpu *cpu, char *file, int size) 
{
	FILE *f;
	int len;
	int result;

	f=fopen(file,"rb");
	
	if(!f) {
		printf("Failed to open rom [%s]\n", file);
		return 0;
	}

	fseek(f, 0, SEEK_END);
	len = ftell(f);
	printf("ROM [%s]\nLENGTH: [0x%X]\n",file, len);
	if(len!=size) {
		fclose(f);
		return 0;
	}
	fseek(f, 0, SEEK_SET);

	result = fread(cpu->rom,1,len,f);

	fclose(f);
	return len;	

}

#ifdef HAS_SDL

void setup_gfx(void) {
	int x = 0;
	int y = 0;
	char filename[255];
	
	IMG_Init(IMG_INIT_PNG);
	SDL_Rect rect;
	memset(gfx_x,0,sizeof(gfx_x));
	memset(gfx_y,0,sizeof(gfx_y));
	
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
			sprintf(filename,"data/gfx/%d.%d.png",y,x);
			gfx[y][x]=IMG_Load(filename);		
			if(gfx[y][x]) {
				rect.x=gfx_x[y][x];
				rect.y=gfx_y[y][x];
				rect.w=gfx[y][x]->w;
				rect.h=gfx[y][x]->h;
//				printf("Loaded %s\n",filename);
				SDL_BlitSurface(gfx[y][x],NULL, screen,&rect);
			}	
		}
	}

	SDL_Flip(screen);
}

void display_update(void) {
	int x,y;
	SDL_Rect rect;

	SDL_FillRect(screen, NULL, SDL_MapRGB(screen->format, 0,0,0));
	for(x=0;x<15;x++) {
		for(y=0;y<10;y++) {
			if(gfx[y][x] && (cpu.display_cache[y]&1<<x)) {
				rect.x=gfx_x[y][x];
				rect.y=gfx_y[y][x];
				rect.w=gfx[y][x]->w;
				rect.h=gfx[y][x]->h;
	//			printf("Loaded %s\n",filename);
				SDL_BlitSurface(gfx[y][x],NULL, screen,&rect);
			}	

		}
	}
	SDL_Flip(screen);

}
#endif

int totalticks = 0;
int running = 1;

struct timeval tv;
static long ms = 0;
static long next_ms = 0;
SDL_Event event;

unsigned long long get_ms() {
	gettimeofday(&tv, NULL);
	unsigned long long millisecondsSinceEpoch =
    (unsigned long long)(tv.tv_sec) * 1000 +
    (unsigned long long)(tv.tv_usec) / 1000;
    return millisecondsSinceEpoch;
}

uint8_t inputs[5];

void mainloop(void) {

	uint8_t bit;
	ms = get_ms();

//	printf("%lu %lu\n",ms, next_ms);

	if( ms >= next_ms )
		next_ms += 1000/60;
	else
		return;


	//int ticks = 0;
//printf("mainloop\n");
//		ucom4_exec(&cpu, 400000/60);
//		printf("%d\n",ucom4_exec(&cpu, 1));//400000/60));
		totalticks +=ucom4_exec(&cpu, 400000/284);
//		totalticks +=ucom4_exec(&cpu, 220);
//		printf("PC: %02X TC: %d  TT: %d   \n",cpu.rom[cpu.pc],cpu.tc, totalticks);
/*		for(x=0;x<0x80;x++) {
			printf("%X ",cpu.ram[x]);
			if(x%16==15)
				printf("\n");
		}
		printf("Stack: %02X %02X %02X %02X \n",cpu.pc, cpu.stack[0], cpu.stack[0],cpu.stack[1]);
*/
		// printf("OUTPUT: ");
		// for(x=0;x<16;x++) {
		// 	printf("%2X ",cpu.port_out_buf[x]);
		// 	cpu.port_out_buf[x]=0;
		// }
		// printf("\r");

//		ucom4_display_decay(&cpu);

//		ucom4_display_update(&cpu);		

#ifdef HAS_SDL
		while(SDL_PollEvent( &event)) {
			bit = 0;
			if(event.type == SDL_KEYDOWN)
				bit=1;

			switch( event.type ) {

				case SDL_KEYDOWN:
				case SDL_KEYUP:
					switch(event.key.keysym.sym) {

						case SDLK_SPACE: // FIRE
							inputs[0]=bit;
							break;

						case SDLK_LEFT: // LEFT
							inputs[1]=bit;
							break;

						case SDLK_RIGHT: // RIGHT
							inputs[2]=bit;
							break;

						case SDLK_2: // SELECT
							inputs[3]=bit;
							break;

						case SDLK_1: // START
							inputs[4]=bit;
							break;
					}
					break;
				case SDL_QUIT:
					running = 0;
					break;
			}
		}
		display_update();
#else
		for(x=0;x<cpu.display_maxy;x++) {
			for(y=cpu.display_maxx-1;y>=0;y--) {
				printf("%d",(cpu.display_cache[x]&1<<y)?1:0);
			}
			printf("\n");
		}
		printf("\n");
#endif

		// replace this with proper FPS ticker
//		usleep(10000000/200);


}

static uint8_t *audio_chunk;
static uint32_t audio_len;
static uint8_t *audio_pos;

extern uint8_t audiobuf[1024];
extern int aindex;
extern int audiosize;

SDL_AudioSpec wanted;
int a  = 0;
int last_a = 0;

void fill_audio(void *udata, Uint8 *stream, int len)
{

	double Hz = 50;
	double pi = 3.1415; 
	double SR = 22050; 
	double F=2*pi*Hz/SR;

	uint8_t soundbuf[1024];
	int z;

	// if(cpu.aindex < last_a) {
	// 	// index has looped since we checked
	// 	audio_len = 8192-a+cpu.aindex;
	// } else {
	// 	audio_len = cpu.aindex -a;
	// }

	audio_len = cpu.audio_avail;



        /* Mix as much data as possible */
        len = ( len > audio_len ? audio_len : len );

        /* Only play if we have data left */
        // if ( audio_len == 0 )
        //     return;
//		printf("cpu.audio_level: %d\n",cpu.audio_level);

//		printf("audio buf: %d audio pos: %d\n",a, cpu.aindex);
    	for(z=0;z<len;z++) {
			stream[z] = audiobuf[a];//(rand()*1)*255;//(uint8_t)audiobuf[a];//*sin(F*(double)z); 
			a++;
			if(a>=10240)
				a=0;
    	}

    	cpu.audio_avail -= len;
//    	printf("Filling audio stream %d\n", len);

//        SDL_MixAudio(stream, soundbuf, len, SDL_MIX_MAXVOLUME);
        audio_pos += len;
        audio_len -= len;
//		printf("Audio reserve: %d\n",cpu.audio_avail);

}

int init_sound(void) {

    /* Set the audio format */
    wanted.freq = 11025;
    wanted.format = AUDIO_U8;
    wanted.channels = 1;    /* 1 = mono, 2 = stereo */
    wanted.samples = 256;   /* Good low-latency value for callback */
    wanted.callback = fill_audio;
    wanted.userdata = NULL;

    /* Open the audio device, forcing the desired format */
    if ( SDL_OpenAudio(&wanted, NULL) < 0 ) {
        fprintf(stderr, "Couldn't open audio: %s\n", SDL_GetError());
        return(-1);
    }
    printf("Opened sound\n");

    return(0);
}


int main(int argc, char *argv[])
{
	int x,y;
#ifdef HAS_SDL

	SDL_Init(SDL_INIT_EVERYTHING | SDL_INIT_AUDIO);
	screen = SDL_SetVideoMode(193,684,32,SDL_HWSURFACE);
	setup_gfx();
	init_sound();

#endif

	next_ms = get_ms();
	//round(spec.tv_nsec / 1.0e6); // Convert nanoseconds to milliseconds

	ucom4_reset(&cpu);
	if(load_rom(&cpu, "data/astrowars.rom", 0x800)!=0x800) {
		printf("Failed to load astrowars.rom\n");
		return -1;
	}
	SDL_PauseAudio(0);
#ifdef __EMSCRIPTEN__
	emscripten_set_main_loop(mainloop,60,0);
#else
	while(running) {
		mainloop();
//		usleep(10000000/282);
	}
	SDL_Quit();
#endif
	return 0;
}
