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
    m_family;
    m_int_f;
    m_inte_f;
    m_icount;
    m_skip;

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

                case 0xA0:
                    op_jmp();
                end
            end
        end
    end
    frame;

END

END


// ram rw

function ram_w(value)

PRIVATE

WORD addr;

BEGIN

    addr = cpu.m_dph << 4 | cpu.m_dpl;
    cpu.ram[addr]=value;
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


END



// Interrupt

function interrupt()

BEGIN

cpu.m_icount --;
push_stack();
cpu.m_pc = 0xf << 2;
cpu.m_int_f = 0;
cpu.m_inte_f = (cpu.m_family != NEC_UCOM43);

END


// opcodes

// 00 - NOP

function op_nop()

BEGIN
// NOTHING! HURRAH!
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
function op_s()

BEGIN

    ram_w(cpu.m_acc);

END

// 03 - TIT
function op_tit()

BEGIN


END

// 04 - TC
function op_tc()

BEGIN


END

// 05 - TTM
function op_ttm()

BEGIN


END

// 0x80 - LDZ
function op_ldz()

BEGIN


END

// 0x90 - LI
function op_li()
BEGIN

FRAME;

END

// 0xA0 - JMPCAL
function op_jmpcal()

BEGIN


END

// 0xB0 - CZP
function op_czp()

BEGIN


END

// 0xC0 0xD0 0xE0 0xF0 - JCP
function op_jcp()

BEGIN


END




function op_stm()
BEGIN

DEBUG;

END

function op_jmp()

BEGIN

DEBUG;

END
