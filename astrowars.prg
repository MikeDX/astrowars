/*
 * astrowars.prg by MikeDX
 * (c) 2016 DX Games
 */

PROGRAM astrowars;
GLOBAL

// CPU definition
STRUCT cpu
    m_pc;
    BYTE rom[2048];
END


BEGIN

//Write your code here, make something amazing!


// Load ROM
load("d553c-153.s01",&cpu.rom);

reset();
DEBUG;

END

function reset()
BEGIN

cpu.m_pc = 0;

END


function emulate(ticks)

BEGIN

END


