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

// CPU definition
STRUCT cpu
    WORD m_pc;
    WORD m_prev_pc;
    BYTE m_op;
    BYTE m_prev_op;
    BYTE m_acc;
    BYTE m_arg;
    BYTE m_bitmask;
    m_int_f;
    m_inte_f;
    m_icount;
    m_skip;

    BYTE rom[2048];
END


BEGIN

//Write your code here, make something amazing!


// Load ROM
load("d553c-153.s01",&cpu.rom);

reset();
write_int(0,0,0,0,&cpu.m_pc);
write_int(0,0,10,0,&cpu.m_arg);

LOOP

cpu.m_icount = 400;
emulate();
FRAME;
END


END

function reset()
BEGIN

cpu.m_pc = 0;
cpu.m_op = 0;

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

    switch(cpu.m_op & 0xf0)
        case 0x90:
            op_li();
        end

        default:
            switch(cpu.m_op)
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




// Interrupt

function interrupt()

BEGIN

END


// opcodes

function op_li()
BEGIN

FRAME;

END


function op_stm()
BEGIN

DEBUG;

END

function op_jmp()

BEGIN

DEBUG;

END
