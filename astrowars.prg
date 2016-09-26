/*
 * astrowars.prg by MikeDX
 * (c) 2016 DX Games
 *
 * Many thanks to the MAME driver by hap,
 * which much of this information and inspiration comes from
 *
 */

PROGRAM astrowars;

CONST

NEC_UCOM43 = 0;
STACK_SIZE = 4;

NEC_UCOM4_PORTA = 0;
NEC_UCOM4_PORTB = 1;
NEC_UCOM4_PORTC = 2;
NEC_UCOM4_PORTD = 3;
NEC_UCOM4_PORTE = 4;
NEC_UCOM4_PORTF = 5;
NEC_UCOM4_PORTG = 6;
NEC_UCOM4_PORTH = 7;
NEC_UCOM4_PORTI = 8;

UCOM43_X = 0;
UCOM43_Y = 1;
UCOM43_R = 2;
UCOM43_S = 3;
UCOM43_W = 4;
UCOM43_Z = 5;
UCOM43_F = 6;


GLOBAL
ram[255];
registers[8];

real_op = 0;
readport = 0;
// CPU definition
d = true;
bp = 165824;

STRUCT dbg
    string pc;
    string dp;
END


struct vfd[15]
int y[10];
end


string dbgstack0;
string dbgstack1;
string dbgstack2;
string dbgstack3;



STRUCT cpu
    WORD pc;
    WORD m_prev_pc;
    BYTE m_op;
    BYTE m_prev_op;

    BYTE skip;
    BYTE m_arg;
    BYTE acc;
    WORD stack[4];
    BYTE port_out_but[0x10];
    INT tc;

    BYTE m_bitmask;

    BYTE m_dpl;
    BYTE m_dph;
    BYTE m_dph_mask;
    BYTE carry_f;
    BYTE int_f;
    BYTE m_carry_s_f;

    BYTE m_timer_f;
    m_time;
    m_timeout;
    m_tc;
    BYTE m_family;

//    m_int_f;
    m_inte_f;
    m_icount;
    m_oldicount;

    m_tickcount;

    m_skip;
    WORD m_prgmask;
    m_prgwidth;
    m_datawidth;
    m_datamask;

    WORD grid;
    WORD plate;

    INT display_wait;
    INT display_maxx;
    INT display_maxy;


    int display_state[0x20];
    WORD display_segmask[0x20];
    INT display_cache[0x20];
    STRUCT display_decay[0x20];
        INT x[0x20];
    END

    //int display_decay[0x20][0x20];

    int decay_ticks;

    BYTE rom[2048];
    BYTE ram[2048];
    BYTE m_port_out[0x10];
    BYTE registers[16];

END


BEGIN

//Write your code here, make something amazing!


// Load ROM
load("d553c-153.s01",&cpu.rom);
//set_mode(640480);
set_fps(60,0);
//load_fpg("graphics.fpg");
//put_screen(0,1);
reset();
write_int(0,320,0,2,&fps);
write(0,100, 0,0,&dbg.pc);
write(0,100,10,0,&dbgstack0);
write(0,100,20,0,&dbgstack1);
write(0,100,30,0,&dbgstack2);

write(0,0,0,0,"ACC: ");
write_int(0,30,0,0,&cpu.acc);
write(0,0,10,0," DP: ");
write(0,30,10,0,&dbg.dp);
write(0,0,20,0," TC: ");
write_int(0,30,20,0,&cpu.m_tc);

write(0,0,30,0,"  Y: ");
write_int(0,30,30,0,&registers[UCOM43_Y]);

write_int(0,0,80,0,&cpu.m_tickcount);


write_int(0,0,40,0,&cpu.grid);
write_int(0,0,50,0,&cpu.plate);


for(x=0;x<12;x++)
    write_int(0,x*30,70,0,&cpu.display_cache[x]);
end




write_int(0,0,90,0,&cpu.m_skip);


//write_int(0,0,70,0,&cpu.m_port_out);
//write_int(0,0,80,0,&cpu.m_port_out[1]);
//write_int(0,0,90,0,&cpu.m_port_out[2]);

for(x=0;x<16;x++)
for(y=0;y<8;y++)

ram[x+y*16]=x+y*16;
write_int(0,10+x*20,100+y*10,1,&vfd[x].y[y]);//cpu.display_decay[y].x[x]);//ram[x+y*16]);//&ram[x+(y*16)]);
end
end

//loop
//frame;
//end


LOOP

// dunno how this works. guess
cpu.m_icount += 100000/fps;
emulate();
//cpu.m_inte_f =1 ;
//cpu.m_int_f = 1;


//cpu.m_timer_f = 1;

FRAME;
END


END

function reset()
BEGIN

cpu.pc = 0;
cpu.tc = 0;
cpu.acc = 0;
cpu.carry_f = 0;
cpu.int_f = 0;
cpu.m_op = 0;
cpu.m_arg = 0;
cpu.m_skip = false;
cpu.m_family = NEC_UCOM43;
cpu.m_icount = 0;
cpu.m_timer_f = 0;
cpu.m_tc = 0;
cpu.m_timeout = 0;
cpu.m_time = 0;
cpu.m_dpl = 0;
cpu.m_dph = 0;
cpu.m_tickcount = 0;

// 2k ROM
cpu.m_prgmask = 0x7FF;
cpu.m_datamask = 0x7F;

cpu.display_wait = 33;
cpu.decay_ticks = 0;
cpu.plate = 0;
cpu.grid = 0;

END


function emulate()

BEGIN

WHILE(cpu.m_icount>0)

    IF(cpu.int_f > 0 && cpu.m_inte_f > 0 && (cpu.m_op & 0xf0) != 0x90 && cpu.m_op !=0x31 && cpu.m_skip==false)
        interrupt();
        if(cpu.m_icount <=0)
            break;
        END
    END

    cpu.m_oldicount = cpu.m_icount;

    cpu.m_prev_op = cpu.m_op;
    cpu.m_prev_pc = cpu.m_prev_pc;

    cpu.m_icount--;

    cpu.m_op = cpu.rom[cpu.pc];

    cpu.m_bitmask = 1 << (cpu.m_op &0x03);

    inc_pc();
    fetch_arg();

    if(cpu.m_skip == true)
//        debug;
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

                case 0x05:
                    op_ttm();
                end

                case 0x06:
                    op_daa();
                end

                case 0x07:
                    op_tal();
                end

                case 0x08:
                    op_ad();
                end

                case 0x09:
                    op_ads();
                end

                case 0x0A:
                    op_das();
                end

                case 0x0B:
                    op_clc();
                end

                case 0x0C:
                    op_cm();
                end

                case 0x0D:
                    op_inc();
                end

                case 0x0E:
                    op_op();
                end

                case 0x0F:
                    op_dec();
                end

                case 0x10:
                    op_cma();
                end

                case 0x11:
                    op_cia();
                end

                case 0x12:
                    op_tla();
                end

                case 0x13:
                    op_ded();
                end

                case 0x14:
                    op_stm();
                end

                case 0x15:
                    op_ldi();
                end

                case 0x16:
                    op_cli();
                end

                case 0x17:
                    op_ci();
                end

                case 0x18:
                    op_exl();
                end

                case 0x19:
                    op_adc();
                end

                case 0x1A:
                    op_xc();
                end

                case 0x1B:
                    op_stc();
                end

                case 0x1C:
                    op_illegal();
                end

                case 0x1D:
                    op_inm();
                end

                case 0x1E:
                    op_ocd();
                end

                case 0x1F:
                    op_exl();
                end


                case 0x30:
                    op_rar();
                end

                case 0x31:
                    op_ei();
                end

                case 0x32:
                    op_ip();
                end

                case 0x33:
                    op_ind();
                end


                case 0x40:
                    op_ia();
                end

                case 0x41:
                    op_jpa();
                end

                case 0x42:
                    op_taz();
                end

                case 0x43:
                    op_taw();
                end

                case 0x44:
                    op_oe();
                end

                case 0x45:
                    op_illegal();
                end

                case 0x46:
                    op_tly();
                end

                case 0x47:
                    op_thx();
                end

                case 0x48:
                    op_rt();
                end

                case 0x49:
                    op_rts();
                end

                case 0x4a:
                    op_xaz();
                end

                case 0x4b:
                    op_xaw();
                end

                case 0x4c:
                    op_xls();
                end

                case 0x4d:
                    op_xhr();
                end

                case 0x4e:
                    op_xly();
                end

                case 0x4f:
                    op_xhx();
                end


                default:
                    real_op = cpu.m_op & 0xfc;

                    switch(cpu.m_op &0xfc)

                        case 0x20:
                            op_fbf();
                        end

                        case 0x24:
                            op_tab();
                        end

                        case 0x28:
                            op_xm();
                        end

                        case 0x2c:
                            op_xmd();
                        end

                        case 0x34:
                            op_cmb();
                        end

                        case 0x38:
                            op_lm();
                        end

                        case 0x3C:
                            op_xmi();
                        end

                        case 0x50:
                            op_tpb();
                        end

                        case 0x54:
                            op_tpa();
                        end

                        case 0x58:
                            op_tmb();
                        end

                        case 0x5c:
                            op_fbt();
                        end

                        case 0x60:
                            op_rpb();
                        end

                        case 0x64:
                            op_reb();
                        end

                        case 0x68:
                            op_rmb();
                        end

                        case 0x6c:
                            op_rfb();
                        end

                        case 0x70:
                            op_spb();
                        end

                        case 0x74:
                            op_seb();
                        end

                        case 0x78:
                            op_smb();
                        end

                        case 0x7c:
                            op_sfb();
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

    cpu.m_tickcount += (cpu.m_oldicount - cpu.m_icount);
    cpu.decay_ticks += (cpu.m_oldicount - cpu.m_icount);


    if(cpu.m_timer_f == 0)
        //cpu.m_timeout -= (cpu.m_oldicount - cpu.m_icount);
        cpu.m_time += (cpu.m_oldicount - cpu.m_icount);
        //if(cpu.m_timeout<=0)

        cpu.m_tc = cpu.m_timeout - cpu.m_time;

        if(cpu.m_tc<0)
            cpu.m_tc = 0;
        end

        if(cpu.m_tc == 0)
        //cpu.m_timeout)
        //    DEBUG;
            cpu.m_timer_f = 1;
        end

    end

    if(false)
    dbg.pc = int2hex(cpu.pc);
    dbg.dp = int2hex(cpu.m_dph << 4 | cpu.m_dpl);

    dbgstack0=int2hex(cpu.stack[0]);
    dbgstack1=int2hex(cpu.stack[1]);
    dbgstack2=int2hex(cpu.stack[2]);
    dbgstack3=int2hex(cpu.stack[3]);
    end

    //dbg.pc[0]="a";
    //dbg.pc[1]="b";

    if(key(_esc) || cpu.m_tickcount == bp)
        d = true;
    end




    if(d)
        frame;

        while(!key(_space) && !key(_z) && !key(_r) && !key(_g))
            frame;
        end


        if(key(_r))
            reset();
        end

        if(key(_g))
            d = false;
        end


        while(key(_space) || key(_r))
            frame;
        end
    end



//    debug;
END

END

function int2hex(INT val)

PRIVATE

STRING str;
STRING str2;

INT high;
INT low;

begin
    return (itoa(val));

    high = val >> 8;
    low = val &0xFF;

    if(high>0)
        str=byte2hex(high);
    end

    str2=byte2hex(low);

    strcat(str,str2);

   // DEBUG;
    return (str);

end


function byte2hex(val)

PRIVATE

INT high;
INT low;
STRING str;
STRING strh;
STRING strl;
BEGIN
    return (itoa(val));

    high = val >> 4;
    low = val &0xf;

    if(high<10)
        strh=itoa(high);
    else
        strh=n2h(high);
    end

    if(low<10)
        strl=itoa(low);
    else
        strl=n2h(low);
    end

    strcat(strh,strl);
    if(strcmp(strh,"") == 0)
        DEBUG;
    END


    return (strh);

END

function n2h(val)

BEGIN

    switch(val)
        case 10:
            return ("A");
        end

        case 11:
            return ("B");
        end

        case 12:
            return ("C");
        end

        case 13:
            return ("D");
        end

        case 14:
            return ("E");
        end

        case 15:
            return ("F");
        end


    end

    return ("X");

end

// ram rw

function ram_w(value)

PRIVATE

WORD addr;

BEGIN

    addr = cpu.m_dph << 4 | cpu.m_dpl;
    cpu.ram[addr & cpu.m_datamask]=value&0xf;
    ram[addr & cpu.m_datamask]=value&0xf;
/*
    if(value!=0)
        d = true;
        DEBUG;
    end

*/
END

function ram_r()

PRIVATE

WORD addr;

BEGIN

    addr = cpu.m_dph << 4 | cpu.m_dpl;
    DEBUG;
    return (cpu.ram[addr & cpu.m_datamask] & 0xf);


END


// STACK

function push_stack()

BEGIN
    for(x=3;x>0;x--)
        cpu.stack[x]=cpu.stack[x-1];
    end
    cpu.stack[0]= cpu.pc;
END


function pop_stack()
BEGIN

    cpu.pc = cpu.stack[0];

    for(x=0;x<3;x++)
        cpu.stack[x]=cpu.stack[x+1];
    end

END


// PORTS

function level_w(value)

BEGIN

END

function BIT(x,y)

BEGIN

return ((x>y)&1);

END

function BITSWAP16(val, B15, B14, B13, B12, B11, B10, B9, B8,
                   B7, B6, B5, B4, B3, B2, B1, B0)

private
ret;

begin

    ret =
        BIT(val, B15) << 15 |
        BIT(val, B14) << 14 |
        BIT(val, B13) << 13 |
        BIT(val, B12) << 12 |
        BIT(val, B11) << 11 |
        BIT(val, B10) << 10 |
        BIT(val, B9) << 9 |
        BIT(val, B8) << 8 |
        BIT(val, B7) << 7 |
        BIT(val, B6) << 6 |
        BIT(val, B5) << 5 |
        BIT(val, B4) << 4 |
        BIT(val, B3) << 3 |
        BIT(val, B2) << 2 |
        BIT(val, B1) << 1 |
        BIT(val, B0);


    return (ret);

END

function set_display_size(maxx, maxy)

BEGIN

    cpu.display_maxx = maxx;
    cpu.display_maxy = maxy;


END

function display_decay()

BEGIN


    for(x=0; x < cpu.display_maxx; x++)
        for(y=0; y < cpu.display_maxy; y++)
            if(cpu.display_decay[y].x[x] >0)
                cpu.display_decay[y].x[x]--;
                DEBUG;
            end
        end
    end


END


function display_update()

PRIVATE
INT active_state[0x20];
INT ds;
INT mul;
INT decay_time = 80;

BEGIN


    DEBUG;


    while(cpu.decay_ticks >= decay_time)
        cpu.decay_ticks -= decay_time;
        display_decay();
    end


    for(y=0; y< cpu.display_maxy; y++)
        active_state[y] = 0;

        for (x=0; x<= cpu.display_maxx; x++)
            DEBUG;
            if(((cpu.display_state[y] >> x) & 1) > 0)
                cpu.display_decay[y].x[x] = cpu.display_wait;
            end

            if( cpu.display_decay[y].x[x] !=0)
                ds = 1;
            else
                ds = 0;
            end

            active_state[y] |= ( ds << x);
            vfd[x].y[y] = ds;


        end

        cpu.display_cache[y] = active_state[y];

    end


END




function display_matrix(maxx, maxy, setx, sety)

PRIVATE

INT mask;

BEGIN

    mask = (1 << maxx) -1;

    set_display_size(maxx, maxy);

    DEBUG;

    for ( y = 0; y< maxy; y++ )
        if(sety >> y &1)
            DEBUG;
            cpu.display_state[y] = (( setx & mask ) | ( 1 << maxx));
        else
            cpu.display_state[y] = 0;
        end
    end


    display_update();

END



function prepare_display()

PRIVATE

WORD grid;
WORD plate;

BEGIN

    DEBUG;

    grid = BITSWAP16(cpu.grid, 15,14,13,12,11,10,0,1,2,3,4,5,6,7,8,9);
    plate = BITSWAP16(cpu.plate, 15,3,2,6,1,5,4,0,11,10,7,12,14,13,8,9);

    DEBUG;

    display_matrix(15,10,plate,grid);


END


function output_w(port, value)
PRIVATE

shift;

BEGIN
    port &= 0xf;
    value &= 0xf;

    if(port == NEC_UCOM4_PORTI)
        value &=0x7;
    end


    switch(port)
        case NEC_UCOM4_PORTC, NEC_UCOM4_PORTD, NEC_UCOM4_PORTE:

            if(port == NEC_UCOM4_PORTE)
                level_w(value >> 3 &1);
            end

            shift = (port - NEC_UCOM4_PORTC) *4;
            cpu.grid = ( cpu.grid & (0xFF - ( 0xf << shift) )) | ( value << shift );
            prepare_display();
        end


        case NEC_UCOM4_PORTF,
             NEC_UCOM4_PORTG,
             NEC_UCOM4_PORTH,
             NEC_UCOM4_PORTI:


            shift = (port - NEC_UCOM4_PORTF) *4;
            cpu.plate = ( cpu.plate & (0xFF - ( 0xf << shift) )) | ( value << shift );
            DEBUG;
            prepare_display();
        end


    end


    cpu.m_port_out[port]=value;


END

function input_r(port)

PRIVATE

BYTE inp;

BEGIN

    readport = port;
    inp = 0;

    switch(port)
        case NEC_UCOM4_PORTA:
            if(key(_space))
                inp+=1;
            end

            if(key(_left))
                inp+=2;
            end

            if(key(_right))
                inp+=4;
            end

        end

        case NEC_UCOM4_PORTB:
            if(key(_2))
                inp+=1;
            end

            if(key(_1))
                inp+=2;
            end

        end

    end

    return (inp&0x7);//cpu.m_port_out[port]);

END


// registers

function ucom43_reg_w(reg, value)
BEGIN

//    cpu.registers[reg]=value;
//    registers[reg]=value;

    cpu.ram[cpu.m_datamask-reg]=value;
    ram[cpu.m_datamask-reg]=value;

    DEBUG;

END

function ucom43_reg_r(reg)
BEGIN

    DEBUG;
    return(cpu.ram[cpu.m_datamask-reg]);//registers[reg]);
END


function check_op_43()
BEGIN

//if(cpu.m_family != NEC_UCOM43)
return (cpu.m_family == NEC_UCOM43);
END


function inc_pc()

begin

// increment pc, but only lower 8 bits
//cpu.m_pc++;
//cpu.m_pc &=0xFF;
cpu.pc = (cpu.pc &0xFF00) | ((cpu.pc +1) & 0xFF);

end


function fetch_arg()

begin

// only 2 byte opcodes have args
if ((cpu.m_op & 0xfc) == 0x14 || (cpu.m_op & 0xf0) == 0xa0 || cpu.m_op == 0x1e)
    cpu.m_icount--;
    cpu.m_arg = cpu.rom[cpu.pc];
    inc_pc();
end

end





// Interrupt
// Astro Wars doesnt use interrupts

function interrupt()

BEGIN

cpu.m_icount --;
push_stack();
cpu.pc = 0xf << 2;
cpu.int_f = 0;
cpu.m_inte_f = (cpu.m_family != NEC_UCOM43);

DEBUG;

END


// opcodes


// Illegal opcodes
// Should never be called
function op_illegal()
BEGIN
    DEBUG;
END

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
    debug;

END

// 02 - S
// Store ACC to RAM
function op_s()

BEGIN

    ram_w(cpu.acc);

END

// 03 - TIT
// Interrupt
function op_tit()

BEGIN
    if(cpu.int_f !=0)
        cpu.m_skip = true;

    // not needed?
    else
        cpu.m_skip = false;
    end
    cpu.int_f = 0;

    debug;
END

// 04 - TC
function op_tc()

BEGIN
    if(cpu.carry_f !=0)
        cpu.m_skip = true;
    else
        cpu.m_skip = false;
    end

END

// 05 - TTM
function op_ttm()

BEGIN

    if(!check_op_43())
        return;
    end

    if(cpu.m_timer_f == 1)
        cpu.m_skip = true;
    end

END


// 06 - DAA
function op_daa()

BEGIN

    cpu.acc = ( cpu.acc + 6 ) &0xf;
END


// 07 - TAL
function op_tal()

BEGIN

    cpu.m_dpl = cpu.acc;
END

// 08 - AD
function op_ad()

BEGIN

    cpu.acc += ram_r();
    if(( cpu.acc & 0x10) !=0)
        cpu.m_skip = true;
    end

    cpu.acc &= 0xf;

END


// 09 - ADS
function op_ads()

BEGIN

    op_adc();
    if( cpu.carry_f !=0)
        cpu.m_skip = true;
    end

END


// 0a - DAS
function op_das()

BEGIN

    cpu.acc = ( cpu.acc + 10 ) &0xf;


END


// 0b - CLC
function op_clc()

BEGIN

    cpu.carry_f = 0;


END

// 0c - CM
function op_cm()

BEGIN

    if ( cpu.acc == ram_r())
        cpu.m_skip = true;
    end

END


// 0d - INC
function op_inc()

BEGIN

    cpu.acc = ( cpu.acc + 1 ) & 0xf;

    if( cpu.acc == 0)
        cpu.m_skip = true;
    end

END


// 0e - OP
function op_op()

BEGIN

    output_w(cpu.m_dpl, cpu.acc);

END


// 0f - DEC
function op_dec()

BEGIN

    cpu.acc = ( cpu.acc - 1 ) & 0xf;

    if ( cpu.acc == 0x0f)
        cpu.m_skip = true;
    end

END


// 10 - CMA
function op_cma()
BEGIN

    cpu.acc ^= 0xf;
END

// 11 - CIA
function op_cia()
BEGIN

    DEBUG;
END

// 12 - TLA
function op_tla()
BEGIN

    DEBUG;
END


// 0x13 - DED
function op_ded()
BEGIN

    cpu.m_dpl = (cpu.m_dpl -1) &0xf;

    if(cpu.m_dpl == 0xf)
        cpu.m_skip = true;
        debug;
    end

END


// 0x14 - STM
function op_stm()
BEGIN

    if(!check_op_43())
        debug;
        return;
    end

    if(cpu.m_timer_f == 0)
//        DEBUG;
    end

    cpu.m_timer_f = 0;

    // Set a timer to fire at m_arg * 640usec
    // TODO

    cpu.m_timeout = ((cpu.m_arg &0x3f) +1)*63 + (cpu.m_oldicount - cpu.m_icount);
    cpu.m_time = 0;
    //cpu.m_oldicount = cpu.m_icount;

  //  DEBUG;

END


// 15 - LDI X
// LOAD DP with X
function op_ldi()

BEGIN
    cpu.m_dph = cpu.m_arg >> 4 & 0xf;
    cpu.m_dpl = cpu.m_arg & 0xf;

END


// 16 - CLI
function op_cli()
BEGIN

    if ( cpu.m_dpl == ( cpu.m_arg & 0xf))
        cpu.m_skip = true;
    end

END


// 17 - CI
function op_ci()
BEGIN

    if ( cpu.acc == (cpu.m_arg & 0xf) )
        cpu.m_skip = true;
    end

END


// 18 - EXL
function op_exl()
BEGIN

    cpu.acc ^= ram_r();
END


// 19 - ADC
function op_adc()
BEGIN

    cpu.acc += ram_r() + cpu.carry_f;
    cpu.carry_f = cpu.acc >> 4 & 1;
    cpu.acc &= 0xf;

END

// 1A - XC
function op_xc()
BEGIN

    DEBUG;
END


// 1B - STC
function op_stc()

BEGIN

    cpu.carry_f = 1;

END


// 1C - ILLEGAL


// 1D - INM
function op_inm()

PRIVATE
BYTE val;

BEGIN

    if(!check_op_43())
        return;
    end

    val = (ram_r() +1) & 0xf;
    ram_w(val);

    if(val == 0)
        cpu.m_skip = true;
    end
END


// 1E - OCD
function op_ocd()

BEGIN

    output_w(NEC_UCOM4_PORTD, cpu.m_arg >> 4);
    output_w(NEC_UCOM4_PORTC, cpu.m_arg & 0xf);
END


// 1F - DEM
function op_dem()
BEGIN

    DEBUG;
END


// 30 - RAR
function op_rar()
PRIVATE

BYTE c;
BEGIN

    if(!check_op_43())
        return;
    end

    c = cpu.acc &1;
    cpu.acc = cpu.acc >> 1 | cpu.carry_f << 3;
    cpu.carry_f = c;


END


// 31 - EI
function op_ei()
BEGIN

    DEBUG;
END


// 32 - IP
function op_ip()
BEGIN

    DEBUG;
END


// 33 - IND
function op_ind()
BEGIN

    cpu.m_dpl = ( cpu.m_dpl + 1) & 0xf;

    if(cpu.m_dpl == 0)
        cpu.m_skip = true;
    end

END


// 40 - IA
function op_ia()
BEGIN

    DEBUG;
END


// 41 - JPA
function op_jpa()
BEGIN

    cpu.m_icount--;
    cpu.pc = (cpu.pc & (0xFFFF - 0x3F)) | (cpu.acc << 2);
END


// 42 - TAZ
function op_taz()
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_icount--;
    ucom43_reg_w(UCOM43_Z, cpu.acc);

END


// 43 - TAW
function op_taw()
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_icount--;
    ucom43_reg_w(UCOM43_W, cpu.acc);

END


// 44 - OE
function op_oe()
BEGIN

    cpu.m_icount--;
    output_w(NEC_UCOM4_PORTE, cpu.acc);
END


// 45 - ILLEGAL


// 0x46 - TLY
function op_tly()

BEGIN
    if(!check_op_43())
        return;
    end

    cpu.m_icount--;
    ucom43_reg_w(UCOM43_Y,cpu.m_dpl);

END


// 47 - THX
function op_thx()
BEGIN

    DEBUG;
END


// 0x48 - RT
function op_rt()

BEGIN
    cpu.m_icount--;
    pop_stack();
END


// 49 - RTS
function op_rts()
BEGIN

    DEBUG;
END


// 4A - XAZ
function op_xaz()

PRIVATE

BYTE old_acc;


BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_icount--;
    old_acc = cpu.acc;
    cpu.acc = ucom43_reg_r(UCOM43_Z);
    ucom43_reg_w(UCOM43_Z, old_acc);

END


// 4B - XAW
function op_xaw()

PRIVATE
BYTE old_acc;

BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_icount--;
    old_acc = cpu.acc;
    cpu.acc = ucom43_reg_r(UCOM43_W);
    ucom43_reg_w(UCOM43_W, old_acc);

END


// 4C - XLS
function op_xls()
BEGIN

    DEBUG;
END


// 4D - XHR
function op_xhr()
BEGIN

    DEBUG;
END


// 0x4E - XLY
function op_xly()

PRIVATE

BYTE old_dpl;

BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_icount--;
    old_dpl = cpu.m_dpl;
    cpu.m_dpl = ucom43_reg_r(UCOM43_Y);
    ucom43_reg_w(UCOM43_Y, old_dpl);

END


// 4F - XHX
function op_xhx()
BEGIN

    DEBUG;
END



// OPS & 0xFC

// 20 - FBF
function op_fbf()
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_icount--;

    if ((ucom43_reg_r(UCOM43_F) & cpu.m_bitmask)==0)
        cpu.m_skip = true;
    end

END


// 24 - TAB
function op_tab()
BEGIN

    if (( cpu.acc & cpu.m_bitmask) !=0)
        cpu.m_skip = true;
    end

END


// 28 - XM  (0x2B)
//
function op_xm()

PRIVATE
BYTE old_acc;

BEGIN

    old_acc = cpu.acc;
    cpu.acc = ram_r();
    ram_w(old_acc);
    cpu.m_dph ^=  (cpu.m_op & 0x03);
END


// 2C - XMD
//
function op_xmd()


BEGIN

    op_xm();
    cpu.m_dpl = (cpu.m_dpl -1) & 0xf;

    if(cpu.m_dpl == 0xf)
        cpu.m_skip = true;
    end

END


// 34 - CMB
function op_cmb()
BEGIN

    DEBUG;
END


// 38

function op_lm()

BEGIN


    cpu.acc = ram_r();
    cpu.m_dph ^= (cpu.m_op &0x03);

END


// 3C - XMI
function op_xmi()
BEGIN

    op_xm();
    cpu.m_dpl = (cpu.m_dpl + 1) & 0xf;

    if ( cpu.m_dpl == 0 )
        cpu.m_skip = true;
    end

END


// 50 - TPB
function op_tpb()
BEGIN

    if (( input_r(cpu.m_dpl) & cpu.m_bitmask )!=0 )
        cpu.m_skip = true;
    end
END


// 54 - TPA
function op_tpa()
BEGIN

    DEBUG;
END


// 58 - TMB
function op_tmb()
BEGIN

    if ((ram_r() & cpu.m_bitmask) !=0)
        cpu.m_skip = true;
    end
END


// 5C - FBT
function op_fbt()
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_icount--;

    if (( ucom43_reg_r(UCOM43_F) & cpu.m_bitmask) !=0)
        cpu.m_skip = true;
    end


END

// 60 - RPB
function op_rpb()
BEGIN

    DEBUG;
END



// 64 - REB
function op_reb()

BEGIN

    cpu.m_icount--;
    output_w(NEC_UCOM4_PORTE, cpu.m_port_out[NEC_UCOM4_PORTE] & (0xFF-cpu.m_bitmask));

END


// 68 - RMB
function op_rmb()
BEGIN

    ram_w(ram_r() & (0xFF - cpu.m_bitmask));
END


// 6C - RFB
function op_rfb()
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_icount--;
    ucom43_reg_w(UCOM43_f, ucom43_reg_r(UCOM43_F) & (0xFF - cpu.m_bitmask));

END


// 70 - SPB
function op_spb()
BEGIN

    DEBUG;
END


// 74 - SEB
function op_seb()
BEGIN

    cpu.m_icount--;
    output_w(NEC_UCOM4_PORTE, cpu.m_port_out[NEC_UCOM4_PORTE] | cpu.m_bitmask);

END


// 78 - SMB
function op_smb()
BEGIN

    ram_w(ram_r() | cpu.m_bitmask);

END


// 7C - SFB
function op_sfb()
BEGIN

     if(!check_op_43())
        return;
     end

     cpu.m_icount--;
     ucom43_reg_w(UCOM43_F, ucom43_reg_r(UCOM43_F) | cpu.m_bitmask);

END



// 0x80 - LDZ
function op_ldz()

BEGIN

    cpu.m_dph = 0;
    cpu.m_dpl = cpu.m_op & 0x0f;

END

// 0x90 - LI
function op_li()
BEGIN

    if((cpu.m_prev_op & 0xf0) != (cpu.m_op & 0xf0))
  //      debug;
        cpu.acc = cpu.m_op & 0x0f;
    end

END

// 0xA0 - JMPCAL
function op_jmpcal()

BEGIN
    if ((cpu.m_op & 0x08) >0)
        push_stack();
    end

    cpu.pc = (( cpu.m_op & 0x07) << 8 | cpu.m_arg) & cpu.m_prgmask;
    //DEBUG;
END

// 0xB0 - CZP
function op_czp()

BEGIN
    push_stack();
    cpu.pc = (cpu.m_op & 0x0f) << 2;
END

// 0xC0 0xD0 0xE0 0xF0 - JCP
function op_jcp()

BEGIN
    cpu.pc = (cpu.pc & (0xFFFF - 0x3F)) | (cpu.m_op & 0x3F);
//    debug;
END






function op_jmp()

BEGIN

    DEBUG;

END
