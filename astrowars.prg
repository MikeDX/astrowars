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
d = false;
STRUCT dbg
    string pc;
    string dp;
END


string dbgstack0;
string dbgstack1;
string dbgstack2;
string dbgstack3;



STRUCT cpu
    WORD m_pc;
    WORD m_prev_pc;
    BYTE m_op;
    BYTE m_prev_op;
    BYTE m_arg;
    BYTE m_bitmask;

    BYTE m_acc;
    BYTE m_dpl;
    BYTE m_dph;
    BYTE m_dph_mask;
    BYTE m_carry_f;
    BYTE m_carry_s_f;

    BYTE m_timer_f;
    m_time;
    m_timeout;
    m_tc;
    BYTE m_family;

    m_int_f;
    m_inte_f;
    m_icount;
    m_oldicount;

    m_tickcount;

    m_skip;
    m_prgmask;
    m_prgwidth;
    m_datawidth;
    m_datamask;

    BYTE rom[2048];
    BYTE ram[2048];
    WORD stack[255];
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
write(0,100, 0,0,&dbg.pc);
write(0,100,10,0,&dbgstack0);
write(0,100,20,0,&dbgstack1);
write(0,100,30,0,&dbgstack2);

write(0,0,0,0,"ACC: ");
write_int(0,30,0,0,&cpu.m_acc);
write(0,0,10,0," DP: ");
write(0,30,10,0,&dbg.dp);
write(0,0,20,0," TC: ");
write_int(0,30,20,0,&cpu.m_tc);

write(0,0,30,0,"  Y: ");
write_int(0,30,30,0,&registers[UCOM43_Y]);

write_int(0,0,80,0,&cpu.m_tickcount);


write_int(0,0,90,0,&cpu.m_skip);


//write_int(0,0,70,0,&cpu.m_port_out);
//write_int(0,0,80,0,&cpu.m_port_out[1]);
//write_int(0,0,90,0,&cpu.m_port_out[2]);

for(x=0;x<16;x++)
for(y=0;y<8;y++)


write_int(0,30+x*14,100+y*10,1,&ram[x+y*16]);
end
end

LOOP

// dunno how this works. guess
cpu.m_icount += 400000/60;
emulate();
//cpu.m_inte_f =1 ;
//cpu.m_int_f = 1;


//cpu.m_timer_f = 1;

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
//cpu.stackptr = 0;//STACK_SIZE;
cpu.m_datamask = 0x7F;

END


function emulate()

BEGIN

WHILE(cpu.m_icount>0)

    IF(cpu.m_int_f>0 && cpu.m_inte_f>0 && (cpu.m_op & 0xf0) != 0x90 && cpu.m_op !=0x31 && cpu.m_skip==false)
        interrupt();
        if(cpu.m_icount <=0)
            break;
        END
    END

    cpu.m_oldicount = cpu.m_icount;

    cpu.m_prev_op = cpu.m_op;
    cpu.m_prev_pc = cpu.m_prev_pc;

    cpu.m_icount--;

    cpu.m_op = cpu.rom[cpu.m_pc];

    cpu.m_bitmask = 1 << (cpu.m_op &0x03);

    inc_pc();
    fetch_arg();

    if(cpu.m_skip == true)
        debug;
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
            DEBUG;
            cpu.m_timer_f = 1;
        end

    end

    dbg.pc = int2hex(cpu.m_pc);
    dbg.dp = int2hex(cpu.m_dph << 4 | cpu.m_dpl);

    dbgstack0=int2hex(cpu.stack[0]);
    dbgstack1=int2hex(cpu.stack[1]);
    dbgstack2=int2hex(cpu.stack[2]);
    dbgstack3=int2hex(cpu.stack[3]);

    //dbg.pc[0]="a";
    //dbg.pc[1]="b";

    if(key(_esc))
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
    if(value!=0)
        d = true;
        DEBUG;
    end
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
    cpu.stack[0]= cpu.m_pc;
END


function pop_stack()
BEGIN

    cpu.m_pc = cpu.stack[0];

    for(x=0;x<3;x++)
        cpu.stack[x]=cpu.stack[x+1];
    end

END


// PORTS

function output_w(port, value)

BEGIN

cpu.m_port_out[port]=value;


END

function input_r(port)

BEGIN

    readport = port;

    return (cpu.m_port_out[port]);

END


// registers

function ucom43_reg_w(reg, value)
BEGIN

    cpu.registers[reg]=value;
    registers[reg]=value;

    DEBUG;

END

function ucom43_reg_r(reg)
BEGIN

    DEBUG;
    return(cpu.registers[reg]);
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
cpu.m_pc = (cpu.m_pc &0xFF00) | ((cpu.m_pc +1) & 0xFF);

end


function fetch_arg()

begin

// only 2 byte opcodes have args
if ((cpu.m_op & 0xfc) == 0x14 || (cpu.m_op & 0xf0) == 0xa0 || cpu.m_op == 0x1e)
    cpu.m_icount--;
    cpu.m_arg = cpu.rom[cpu.m_pc];
    inc_pc();
end

end





// Interrupt
// Astro Wars doesnt use interrupts

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

    ram_w(cpu.m_acc);

END

// 03 - TIT
// Interrupt
function op_tit()

BEGIN
    if(cpu.m_int_f !=0)
        cpu.m_skip = true;

    // not needed?
    else
        cpu.m_skip = false;
    end
    cpu.m_int_f = 0;

    debug;
END

// 04 - TC
function op_tc()

BEGIN
    if(cpu.m_carry_f !=0)
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

    IF(cpu.m_skip)
        DEBUG;
    END

END


// 06 - DAA
function op_daa()

BEGIN

    cpu.m_acc = ( cpu.m_acc + 6 ) &0xf;
END


// 07 - TAL
function op_tal()

BEGIN

    cpu.m_dpl = cpu.m_acc;
END

// 08 - AD
function op_ad()

BEGIN

    cpu.m_acc += ram_r();
    if(( cpu.m_acc & 0x10) !=0)
        cpu.m_skip = true;
    end

    cpu.m_acc &= 0xf;

END


// 09 - ADS
function op_ads()

BEGIN

    op_adc();
    if( cpu.m_carry_f !=0)
        cpu.m_skip = true;
    end

END


// 0a - DAS
function op_das()

BEGIN

    cpu.m_acc = ( cpu.m_acc + 10 ) &0xf;


END


// 0b - CLC
function op_clc()

BEGIN

    cpu.m_carry_f = 0;


END

// 0c - CM
function op_cm()

BEGIN

    if ( cpu.m_acc == ram_r())
        cpu.m_skip = true;
    end

END


// 0d - INC
function op_inc()

BEGIN

    cpu.m_acc = ( cpu.m_acc + 1 ) & 0xf;

    if( cpu.m_acc == 0)
        cpu.m_skip = true;
    end

END


// 0e - OP
function op_op()

BEGIN

    output_w(cpu.m_dpl, cpu.m_acc);

END


// 0f - DEC
function op_dec()

BEGIN

    cpu.m_acc = ( cpu.m_acc - 1 ) & 0xf;

    if ( cpu.m_acc == 0x0f)
        cpu.m_skip = true;
    end

END


// 10 - CMA
function op_cma()
BEGIN

    cpu.m_acc ^= 0xf;
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

    cpu.m_timeout = ((cpu.m_arg &0x3f) +1)*63;
    cpu.m_time = 0;
    cpu.m_oldicount = cpu.m_icount;

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

    if ( cpu.m_acc == (cpu.m_arg & 0xf) )
        cpu.m_skip = true;
    end

END


// 18 - EXL
function op_exl()
BEGIN

    cpu.m_acc ^= ram_r();
END


// 19 - ADC
function op_adc()
BEGIN

    cpu.m_acc += ram_r() + cpu.m_carry_f;
    cpu.m_carry_f = cpu.m_acc >> 4 & 1;
    cpu.m_acc &= 0xf;

END

// 1A - XC
function op_xc()
BEGIN

    DEBUG;
END


// 1B - STC
function op_stc()

BEGIN

    cpu.m_carry_f = 1;

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

    c = cpu.m_acc &1;
    cpu.m_acc = cpu.m_acc >> 1 | cpu.m_carry_f << 3;
    cpu.m_carry_f = c;


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
    cpu.m_pc = (cpu.m_pc & (0xFFFF - 0x3F)) | (cpu.m_acc << 2);
END


// 42 - TAZ
function op_taz()
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_icount--;
    ucom43_reg_w(UCOM43_Z, cpu.m_acc);

END


// 43 - TAW
function op_taw()
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.m_icount--;
    ucom43_reg_w(UCOM43_W, cpu.m_acc);

END


// 44 - OE
function op_oe()
BEGIN

    cpu.m_icount--;
    output_w(NEC_UCOM4_PORTE, cpu.m_acc);
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
    old_acc = cpu.m_acc;
    cpu.m_acc = ucom43_reg_r(UCOM43_Z);
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
    old_acc = cpu.m_acc;
    cpu.m_acc = ucom43_reg_r(UCOM43_W);
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

    if (( cpu.m_acc & cpu.m_bitmask) !=0)
        cpu.m_skip = true;
    end

END


// 28 - XM  (0x2B)
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


    cpu.m_acc = ram_r();
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
        cpu.m_acc = cpu.m_op & 0x0f;
    end

END

// 0xA0 - JMPCAL
function op_jmpcal()

BEGIN
    if ((cpu.m_op & 0x08) >0)
        push_stack();
    end

    cpu.m_pc = (( cpu.m_op & 0x07) << 8 | cpu.m_arg) & cpu.m_prgmask;
    //DEBUG;
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
    cpu.m_pc = (cpu.m_pc & (0xFFFF - 0x3F)) | (cpu.m_op & 0x3F);
//    debug;
END






function op_jmp()

BEGIN

    DEBUG;

END
