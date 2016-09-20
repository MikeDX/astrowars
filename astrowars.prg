/*
 * astrowars.prg by MikeDX
 * (c) 2016 DX Games
 *
 * Many thanks to the MAME driver by hap,
 * which much of this information and inspiration comes from
 *
 */

PROGRAM astrowars;
GLOBAL

NEC_UCOM43 = 0;
real_op = 0;

// CPU definition
STRUCT cpu
    WORD m_pc;
    WORD m_prev_pc;
    BYTE m_op;
    BYTE m_prev_op;
    BYTE m_acc;
    BYTE m_arg;
    BYTE m_bitmask;

    BYTE m_dph;
    BYTE m_dpl;

    BYTE m_timer_f;

    BYTE m_family;

    m_int_f;
    m_inte_f;
    m_icount;
    m_skip;
    m_prgmask;
    m_prgwidth;

    BYTE rom[2048];
    BYTE ram[2048];
END


BEGIN

//Write your code here, make something amazing!


// Load ROM
load("d553c-153.s01",&cpu.rom);

reset();
write_int(0,0,0,0,&cpu.m_pc);
write_int(0,0,10,0,&cpu.m_arg);
write_int(0,0,20,0,&cpu.m_acc);
write_int(0,0,30,0,&cpu.m_op);
write_int(0,0,40,0,&real_op);
write_int(0,0,50,0,&cpu.m_icount);

LOOP

// dunno how this works. guess
cpu.m_icount = 400;
emulate();
FRAME;
END


END

function reset()
BEGIN

cpu.m_pc = 0;
cpu.m_op = 0;
cpu.m_arg = 0;
cpu.m_skip = false;
cpu.m_family = NEC_UCOM43;

// 2k ROM
cpu.m_prgmask = 0x7FF;

END


function emulate()

BEGIN

WHILE(cpu.m_icount>0)

    IF(cpu.m_int_f>0 && cpu.m_inte_f>0 && (cpu.m_op & 0xf0) != 0x90 && cpu.m_op !=0x31 && cpu.m_skip==0)
        interrupt();
        if(cpu.m_icount <=0)
            break;
        END
    END

    cpu.m_prev_op = cpu.m_op;
    cpu.m_prev_pc = cpu.m_prev_pc;

    cpu.m_icount--;

    cpu.m_op = cpu.rom[cpu.m_pc];

    cpu.m_bitmask = 1 << (cpu.m_op &0x03);

    inc_pc();
    fetch_arg();

    if(cpu.m_skip)
        cpu.m_skip = false;
        cpu.m_op = 0; // NOP
    end


    switch(cpu.m_op & 0xf0)

        case 0x80:
            op_ldz();
        end

        case 0x90:
            op_li();
        end

        case 0xa0:
            op_jmpcal();
        end

        case 0xb0:
            op_czp();
        end

        case 0xc0, 0xd0, 0xe0, 0xf0:
            op_jcp();
        end


        default:
            switch(cpu.m_op)
                case 0x00:
                    op_nop();
                end

                case 0x01:
                    op_di();
                end

                case 0x02:
                    op_s();
                end

                case 0x03:
                    op_tit();
                end

                case 0x04:
                    op_tc();
                end

                case 0x14:
                    op_stm();
                end

                case 0x15:
                    op_ldi();
                end

                case 0x48:
                    op_rt();
                end

                default:
                    real_op = cpu.m_op & 0xfc;

                    switch(cpu.m_op &0xfc)
                        case 0x28:
                            op_xm();
                        end
                        case 0x2c:
                            op_xmd();
                        end

                        default:
                            loop;
                                frame;
                            end
                        end

                    end
                end
            end
        end
    end
    frame;
//    debug;
END

END


// ram rw

function ram_w(value)

PRIVATE

WORD addr;

BEGIN

    addr = cpu.m_dph << 4 | cpu.m_dpl;
    cpu.ram[addr]=value;


END

function ram_r()

PRIVATE

WORD addr;

BEGIN

    addr = cpu.m_dph << 4 | cpu.m_dpl;
    return (cpu.ram[addr]);


END


// STACK

function pop_stack()
BEGIN

    DEBUG;

END



function check_op_43()
BEGIN

//if(cpu.m_family != NEC_UCOM43)

return (cpu.m_family == NEC_UCOM43);
END


function inc_pc()

begin

// increment pc, but only lower 8 bits
cpu.m_pc = (cpu.m_pc &0xFF00) | ((cpu.m_pc +1) & 0xFF);

end


function fetch_arg()

begin

// only 2 byte opcodes have args
if ((cpu.m_op & 0xfc) == 0x14 || (cpu.m_op & 0xf0) == 0xa0 || cpu.m_op == 0x1e)
    cpu.m_icount --;
    cpu.m_arg = cpu.rom[cpu.m_pc];
    inc_pc();
end

end


function push_stack()

BEGIN

    DEBUG;

END



// Interrupt

function interrupt()

BEGIN

cpu.m_icount --;
push_stack();
cpu.m_pc = 0xf << 2;
cpu.m_int_f = 0;
cpu.m_inte_f = (cpu.m_family != NEC_UCOM43);

DEBUG;

END


// opcodes

// 00 - NOP

function op_nop()

BEGIN
// NOTHING! HURRAH!
    DEBUG;
END

// 01 - DI (not used for astro wars)
function op_di()

BEGIN

    if(!check_op_43())
        DEBUG;
        return;

    end

    cpu.m_inte_f = 0;

END

// 02 - S
// Store ACC to RAM
function op_s()

BEGIN

    ram_w(cpu.m_acc);

END

// 03 - TIT
// Interrupt
function op_tit()

BEGIN

    cpu.m_skip = (cpu.m_int_f!=0);
    cpu.m_int_f = 0;


END

// 04 - TC
function op_tc()

BEGIN

    DEBUG;

END

// 05 - TTM
function op_ttm()

BEGIN

    DEBUG;
END

// 15 - LDI X
// LOAD DP with X
function op_ldi()

BEGIN
    cpu.m_dph = cpu.m_arg >> 4 & 0xf;
    cpu.m_dpl = cpu.m_arg & 0xf;

END

// 0x48 - RT
function op_rt()

BEGIN
    cpu.m_icount--;
    pop_stack();
END


// 2B - XM  (0x28)
//
function op_xm()

PRIVATE
BYTE old_acc;

BEGIN

    old_acc = cpu.m_acc;
    cpu.m_acc = ram_r();
    ram_w(old_acc);
    cpu.m_dph ^=  (cpu.m_op & 0x03);

END

// 2B - XMD  (0x2c)
//
function op_xmd()


BEGIN

    op_xm();
    cpu.m_dpl = (cpu.m_dpl -1) & 0xf;
    cpu.m_skip = (cpu.m_dpl == 0xf);

END



// 0x80 - LDZ
function op_ldz()

BEGIN

    DEBUG;

END

// 0x90 - LI
function op_li()
BEGIN

    if((cpu.m_prev_op & 0xf0) != (cpu.m_op & 0xf0))
        cpu.m_acc = cpu.m_op & 0x0f;
    end

END

// 0xA0 - JMPCAL
function op_jmpcal()

BEGIN
    if (cpu.m_op & 0x08)
        push_stack();
    end

    cpu.m_pc = (( cpu.m_op & 0x07) << 8 | cpu.m_arg) & cpu.m_prgmask;


END

// 0xB0 - CZP
function op_czp()

BEGIN
    push_stack();
    cpu.m_pc = (cpu.m_op & 0x0f) << 2;

END

// 0xC0 0xD0 0xE0 0xF0 - JCP
function op_jcp()

BEGIN

    cpu.m_pc = ( cpu.m_pc & 0xFF00) | (cpu.m_acc << 2);

END




function op_stm()
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_timer_f = 0;

    // Set a timer to fire at m_arg * 640usec
    // TODO

    DEBUG;

END

function op_jmp()

BEGIN

    DEBUG;

END
