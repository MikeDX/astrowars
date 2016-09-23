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
#include "astrowars.h"

ucom4cpu cpu;

int load_rom(ucom4cpu *cpu, char *file, int size) 
{
	FILE *f;
	int len;

	f=fopen("astrowars.rom","rb");
	
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

	fread(cpu->rom,1,len,f);

	fclose(f);
	return len;	

}

int main(int argc, char *argv[])
{
	int x;
	int totalticks = 0;
	ucom4_reset(&cpu);
	if(load_rom(&cpu, "astrowars.rom", 0x800)!=0x800) {
		return -1;
	}
	while(cpu.pc<0x800) {
//		ucom4_exec(&cpu, 400000/60);
//		printf("%d\n",ucom4_exec(&cpu, 1));//400000/60));
		totalticks +=ucom4_exec(&cpu, 40000/60);
//		totalticks +=ucom4_exec(&cpu, 1);
/*		printf("PC: %02X TC: %d  TT: %d   \n",cpu.rom[cpu.pc],cpu.tc, totalticks);
		for(x=0;x<0x80;x++) {
			printf("%X ",cpu.ram[x]);
			if(x%16==15)
				printf("\n");
		}
		printf("Stack: %02X %02X %02X %02X \n",cpu.pc, cpu.stack[0], cpu.stack[0],cpu.stack[1]);
*/
		printf("OUTPUT: ");
		for(x=0;x<16;x++) {
			printf("%2X ",cpu.port_out_buf[x]);
			cpu.port_out_buf[x]=0;
		}
		printf("\r");
	}
	return 0;
}
