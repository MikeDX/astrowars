#!/bin/make

LIBS=-lSDL -lm -lSDL_image
all: vfdemu

vfdemu: vfd_emu.o caveman.o astrowars.o ucom4_cpu.o lib/SDL_rotozoom.o
	$(CC) *.o lib/*.o $(LIBS) -o vfdemu

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)