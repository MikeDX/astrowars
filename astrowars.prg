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
//registers[8];

real_op = 0;
//readport = 0;
// CPU definition
d = false;
bp = -1;

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
    WORD prev_pc;
    BYTE op;
    BYTE prev_op;
    BYTE skip;
    BYTE arg;
    BYTE acc;
    WORD stack[4];
    BYTE port_out[0x10];
    BYTE port_out_buf[0x10];
    INT  tc;
    BYTE timer_f;
    BYTE dph;
    BYTE dpl;
    BYTE carry_f;
    BYTE carry_s_f;
    BYTE int_f;
    BYTE inte_f;
    BYTE int_line;
    BYTE rom[0x800];
    BYTE ram[0x80];
    BYTE datamask;
    BYTE bitmask;
    WORD prgmask;
    BYTE stack_levels;
    BYTE family;
    INT  icount;
    INT  old_icount;
    BYTE imp_mux;

    WORD grid;
    WORD plate;

    INT  display_wait;
    INT  display_maxy;
    INT  display_maxx;

    INT  display_state[0x20];
    WORD display_segmask[0x20];
    INT  display_cache[0x20];
    STRUCT  display_decay[0x20]
        INT x[0x20];
    END
    INT  decay_ticks;
    BYTE audio_level;
    INT  sound_ticks;
    INT  totalticks;
    INT  aindex;
    INT  audio_avail;

END


BEGIN

//Write your code here, make something amazing!

/*
write_int(0,0,0,0,&x);

loop

x=(0 == false);

frame;
end
*/


// Load ROM
load("d553c-153.s01",&cpu.rom);
set_mode(220600);
set_fps(50,0);
load_fpg("graphics.fpg");
//graph=1;
flags=4;
//put_screen(0,1);
reset();
if(0)
write_int(0,220,0,2,&fps);
write(0,100, 0,0,&dbg.pc);
write(0,100,10,0,&dbgstack0);
write(0,100,20,0,&dbgstack1);
write(0,100,30,0,&dbgstack2);

write(0,0,0,0,"ACC: ");
write_int(0,30,0,0,&cpu.acc);
write(0,0,10,0," DP: ");
write(0,30,10,0,&dbg.dp);
write(0,0,20,0," TC: ");
write_int(0,30,20,0,&cpu.tc);

write(0,0,30,0,"  Y: ");
//write_int(0,30,30,0,&registers[UCOM43_Y]);

write_int(0,0,80,0,&cpu.totalticks);


write_int(0,0,40,0,&cpu.grid);
write_int(0,0,50,0,&cpu.plate);


for(x=0;x<12;x++)
    write_int(0,x*30,70,0,&cpu.display_cache[x]);
end




write_int(0,0,90,0,&cpu.skip);


//write_int(0,0,70,0,&cpu.m_port_out);
//write_int(0,0,80,0,&cpu.m_port_out[1]);
//write_int(0,0,90,0,&cpu.m_port_out[2]);

for(x=0;x<16;x++)
for(y=0;y<10;y++)

ram[x+y*16]=x+y*16;
write_int(0,10+x*20,100+y*10,1,
&vfd[x].y[y]);
//cpu.display_decay[y].x[x]);
//&ram[x+y*16]);//&ram[x+(y*16)]);
end
end

//loop
//frame;
//end

end // debug info


// SETUP GRAPHS
// GRID 0
// DIGIT 1
VFD_Element(0,0,108,19,-1);
VFD_Element(0,1,98,13,-1);
VFD_Element(0,2,88,20,-1);
VFD_Element(0,3,98,29,-1);
VFD_Element(0,4,88,40,-1);
VFD_Element(0,6,108,40,-1);
VFD_Element(0,7,98,49,-1);

// DIGIT 0
VFD_Element(0,11,108-39,19,-1);
VFD_Element(0,8,98-39,13,-1);
VFD_Element(0,10,88-39,20,-1);
VFD_Element(0,12,98-39,29,-1);
VFD_Element(0,9,88-39,40,-1);
VFD_Element(0,13,108-39,40,-1);
VFD_Element(0,14,98-39,49,-1);

// GRID 1
// DIGIT 3
VFD_Element(1,0,108+86,19,-1);
VFD_Element(1,1,98+86,13,-1);
VFD_Element(1,2,88+86,20,-1);
VFD_Element(1,3,98+86,29,-1);
VFD_Element(1,4,88+86,40,-1);
VFD_Element(1,6,108+86,40,-1);
VFD_Element(1,7,98+86,49,-1);

// DIGIT 2
VFD_Element(1,11,108-39+86,19,-1);
VFD_Element(1,8,98-39+86,13,-1);
VFD_Element(1,10,88-39+86,20,-1);
VFD_Element(1,12,98-39+86,29,-1);
VFD_Element(1,9,88-39+86,40,-1);
VFD_Element(1,13,108-39+86,40,-1);
VFD_Element(1,14,98-39+86,49,-1);


// GRID 2
// BULLETS
VFD_Element(2,0,153,121,-1);
VFD_Element(2,1,184,121,200);
VFD_Element(2,6,121,121,200);
VFD_Element(2,7,90,121,200);
VFD_Element(2,4,59,121,200);

// MOTHERSHIPS
VFD_Element(2,3,59,102,-1);
VFD_Element(2,14,90,102,203);
VFD_Element(2,13,121,102,203);
VFD_Element(2,11,152,102,203);
VFD_Element(2,8,183,102,203);

// ALIENS
VFD_Element(2,2,59,140,-1);
VFD_Element(2,5,90,140,-1);
VFD_Element(2,12,121,140,202);
VFD_Element(2,10,152,140,205);
VFD_Element(2,9,183,140,202);


// GRID 3
// BULLETS
VFD_Element(3,3,59,175,-1);
VFD_Element(3,14,90,175,303);
VFD_Element(3,13,121,175,303);
VFD_Element(3,11,152,175,303);
VFD_Element(3,8,183,175,303);

// ALIENS
VFD_Element(3,2,59,196,205);
VFD_Element(3,5,90,196,202);
VFD_Element(3,12,121,196,205);
VFD_Element(3,10,152,196,202);
VFD_Element(3,9,183,196,205);

// MORE BULLETS
VFD_Element(3,4,59,216,303);
VFD_Element(3,7,90,216,303);
VFD_Element(3,6,121,216,303);
VFD_Element(3,0,152,216,303);
VFD_Element(3,1,183,216,303);


// GRID 4
// DOCKING TURRET / ALIEN BODY
VFD_Element(4,2,58,251,-1);
VFD_Element(4,5,89,252,-1);
VFD_Element(4,12,120,252,-1);
VFD_Element(4,10,150,252,-1);
VFD_Element(4,9,182,252,-1);

// ALIEN ARMOUR
VFD_Element(4,3,57,254,-1);
VFD_Element(4,14,88,254,-1);
VFD_Element(4,13,120,254,-1);
VFD_Element(4,11,152,254,-1);
VFD_Element(4,8,183,254,-1);

// MORE BULLETS
VFD_Element(4,4,57,274,-1);
VFD_Element(4,7,88,274,404);
VFD_Element(4,6,120,274,404);
VFD_Element(4,0,151,274,404);
VFD_Element(4,1,182,274,404);

for(x=5;x<9;x++)
switch(x)
    case 5:
        y=58;
    end

    case 6:
        y=117;
    end

    case 7:
        y=175;
    end

    case 8:
        y=235;
    end
end
// GRIDS 5-8
// DOCKING TURRET / ALIEN BODY
VFD_Element(x,2,58,251+y,402);
VFD_Element(x,5,89,252+y,405);
VFD_Element(x,12,120,252+y,412);
VFD_Element(x,10,150,252+y,410);
VFD_Element(x,9,182,252+y,409);

// ALIEN ARMOUR
VFD_Element(x,3,57,254+y,403);
VFD_Element(x,14,88,254+y,414);
VFD_Element(x,13,120,254+y,413);
VFD_Element(x,11,152,254+y,411);
VFD_Element(x,8,183,254+y,408);

// MORE BULLETS
VFD_Element(x,4,57,274+y,404);
VFD_Element(x,7,88,274+y,404);
VFD_Element(x,6,120,274+y,404);
VFD_Element(x,0,151,274+y,404);
VFD_Element(x,1,182,274+y,404);

end


// GRID 9
//PLAYER TOPs
VFD_Element(9,2,56,544,-1);
VFD_Element(9,5,87,544,902);
VFD_Element(9,12,118,544,902);
VFD_Element(9,10,149,544,902);
VFD_Element(9,9,180,544,902);

// PLAYER BASE
VFD_Element(9,4,55,570,-1);
VFD_Element(9,7,86,570,904);
VFD_Element(9,6,117,570,904);
VFD_Element(9,0,148,570,904);
VFD_Element(9,1,179,570,904);

// ALIEN / EXPLOSION SURROUND
VFD_Element(9,3,56,545,-1);
VFD_Element(9,14,87,545,-1);
VFD_Element(9,13,118,545,903);
VFD_Element(9,11,149,545,914);
VFD_Element(9,8,180,545,903);


x=110;
y=300;

LOOP
// dunno how this works. guess
cpu.icount += 100000/50;
emulate();
//cpu.m_inte_f =1 ;
//cpu.m_int_f = 1;


//cpu.m_timer_f = 1;

FRAME;
END


END


PROCESS VFD_Element(grid, pos, x,y, default_graph)
BEGIN

if(default_graph==-1)
    GRAPH = 50*(grid==0)+grid*100+pos;
else
    GRAPH = default_graph;
END

FRAME(6000);
LOOP

if(vfd[pos].y[grid])
    size=100;
else
    size=0;
END

FRAME;

END


END

function reset()
BEGIN

cpu.pc = 0;
cpu.tc = 0;
cpu.acc = 0;
cpu.carry_f = 0;
cpu.dpl = 0;
cpu.skip = 0;
cpu.int_f = 0;
cpu.inte_f = 0;
cpu.icount = 0;
cpu.old_icount = 0;
cpu.bitmask = 0;
cpu.prgmask = 0x7FF;
cpu.datamask = 0x7F;
cpu.family = NEC_UCOM43;
cpu.timer_f = 0;

cpu.plate = 0;
cpu.grid = 0;
cpu.display_wait = 33;
cpu.decay_ticks = 0;
cpu.totalticks = 0;
cpu.audio_avail = 0;


END


function emulate()

PRIVATE

BYTE curticks; // CAN ONLY BE 0 1 or 2

BEGIN

WHILE(cpu.icount>0)

    cpu.old_icount = cpu.icount;

    IF(cpu.int_f > 0 && cpu.inte_f > 0 && (cpu.op & 0xf0) != 0x90 && cpu.op !=0x31 && cpu.skip==false)
        interrupt();
        if(cpu.icount <=0)
            break;
        END
    END


    cpu.prev_op = cpu.op;
    cpu.prev_pc = cpu.prev_pc;

    cpu.icount--;

    cpu.op = cpu.rom[cpu.pc];

    cpu.bitmask = 1 << (cpu.op &0x03);

    inc_pc();
    fetch_arg();

    if(cpu.skip)
        cpu.skip = 0;
        cpu.op = 0; // NOP
    end


    switch(cpu.op & 0xf0)

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
            switch(cpu.op)
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
                    op_dem();
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
                    real_op = cpu.op & 0xfc;

                    switch(cpu.op &0xfc)

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

    curticks = (cpu.old_icount - cpu.icount);

    cpu.totalticks += curticks;
    cpu.decay_ticks += curticks;

    if(cpu.timer_f == 0)

        // decrement timercount by ticks on this opcode
        cpu.tc -= curticks;

        if(cpu.tc<0)
            cpu.tc = 0;
        end

        if(cpu.tc == 0)
            // set timer flag to 1
            cpu.timer_f = 1;
        end

    end

    if(false)
    dbg.pc = int2hex(cpu.pc);
    dbg.dp = int2hex(cpu.dph << 4 | cpu.dpl);

    dbgstack0=int2hex(cpu.stack[0]);
    dbgstack1=int2hex(cpu.stack[1]);
    dbgstack2=int2hex(cpu.stack[2]);
    dbgstack3=int2hex(cpu.stack[3]);
    end

    //dbg.pc[0]="a";
    //dbg.pc[1]="b";

    if(key(_esc) || cpu.totalticks == bp)
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

    addr = cpu.dph << 4 | cpu.dpl;
    cpu.ram[addr & cpu.datamask]=value&0xf;
    ram[addr & cpu.datamask]=value&0xf;
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

    addr = cpu.dph << 4 | cpu.dpl;
//    DEBUG;
    return (cpu.ram[addr & cpu.datamask] & 0xf);


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

return ((x>>y)&1);

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

    for(y=0; y < cpu.display_maxy; y++)
        for(x=0; x < cpu.display_maxx; x++)
            if(cpu.display_decay[y].x[x] >0)
                cpu.display_decay[y].x[x]--;
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

    while(cpu.decay_ticks >= decay_time)
        cpu.decay_ticks -= decay_time;
        display_decay();
    end


    for(y=0; y< cpu.display_maxy; y++)
        active_state[y] = 0;

        for (x=0; x<= cpu.display_maxx; x++)
            if((cpu.display_state[y] >> x))
                cpu.display_decay[y].x[x] = cpu.display_wait;
            end

            ds = ( cpu.display_decay[y].x[x] >0);

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

    for ( y = 0; y< maxy; y++ )
        if((sety >> y &1 >0))
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


    grid = BITSWAP16(cpu.grid, 15,14,13,12,11,10,0,1,2,3,4,5,6,7,8,9);
    plate = BITSWAP16(cpu.plate, 15,3,2,6,1,5,4,0,11,10,7,12,14,13,8,9);

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
        case NEC_UCOM4_PORTC,
             NEC_UCOM4_PORTD,
             NEC_UCOM4_PORTE:

            if(port == NEC_UCOM4_PORTE)
                level_w(value >> 3 &1);
            end

            shift = (port - NEC_UCOM4_PORTC) *4;
            cpu.grid = ( cpu.grid & !( 0xf << shift) ) | ( value << shift );
            prepare_display();
        end


        case NEC_UCOM4_PORTF,
             NEC_UCOM4_PORTG,
             NEC_UCOM4_PORTH,
             NEC_UCOM4_PORTI:


            shift = (port - NEC_UCOM4_PORTF) *4;
            cpu.plate = ( cpu.plate & !( 0xf << shift) ) | ( value << shift );
            prepare_display();
        end


    end


    cpu.port_out[port]=value;


END

function input_r(port)

PRIVATE

BYTE inp;

BEGIN

    port &=0xf;

    //readport = port;
    inp = 0;

    switch(port)
        case NEC_UCOM4_PORTA:
            if(key(_space))
                inp |= 1;
            end

            if(key(_left))
                inp |= 1<<1;
            end

            if(key(_right))
                inp |= 1<<2;
            end

            return(inp&0xf);
        end

        case NEC_UCOM4_PORTB:
            if(key(_2))
                inp |= 1;
            end

            if(key(_1))
                inp |= 1<<1;
            end

            return(inp&0xf);

        end

        default:
            DEBUG;
        end

    end

    // never get here
    return (0);//inp&0xf);//cpu.m_port_out[port]);

END


// registers

function ucom43_reg_w(reg, value)
BEGIN

    cpu.ram[cpu.datamask-reg]=value;
    ram[cpu.datamask-reg]=value;

END

function ucom43_reg_r(reg)
BEGIN

    return(cpu.ram[cpu.datamask-reg]);//registers[reg]);
END


function check_op_43()
BEGIN

//if(cpu.m_family != NEC_UCOM43)
return (cpu.family == NEC_UCOM43);
END


// CORRECT
function inc_pc()

begin

    cpu.pc = (cpu.pc & !0xFF) | ((cpu.pc +1) & 0xFF);

end



// CORRECT
function fetch_arg()

begin

    // only 2 byte opcodes have args
    if ((cpu.op & 0xfc) == 0x14 || (cpu.op & 0xf0) == 0xa0 || cpu.op == 0x1e)
        cpu.icount--;
        cpu.arg = cpu.rom[cpu.pc];
        inc_pc();
    end

end





// Interrupt
// Astro Wars doesnt use interrupts

function interrupt()

BEGIN

    cpu.icount --;
    push_stack();
    cpu.pc = 0xf << 2;
    cpu.int_f = 0;
    cpu.inte_f = (cpu.family != NEC_UCOM43);

END


// opcodes


// Illegal opcodes
// Should never be called
function op_illegal()
// CHECKED
BEGIN
    DEBUG;
END

// 00 - NOP
function op_nop()
// CHECKED
BEGIN
// NOTHING! HURRAH!
if(cpu.op!=0)
    DEBUG;
end

END


// 01 - DI (not used for astro wars)
function op_di()
// CHECKED
BEGIN

    if(cpu.op!=0x1)
        DEBUG;
    end

    if(!check_op_43())
        return;

    end
    // Disable Interrupts
    cpu.inte_f = 0;

END


// 02 - S
// Store ACC to RAM
function op_s()
// CHECKED
BEGIN

    if(cpu.op!=0x2)
        DEBUG;
    end

    ram_w(cpu.acc);

END


// 03 - TIT
// Interrupt
function op_tit()
// CHECKED
BEGIN

    cpu.skip = (cpu.int_f !=0);

    cpu.int_f = 0;

END


// 04 - TC
function op_tc()
// CHECKED
BEGIN

    cpu.skip = (cpu.carry_f !=0);

END


// 05 - TTM
function op_ttm()
// CHECKED
BEGIN

    if(!check_op_43())
        return;
    end

    if(cpu.timer_f != 0)
        cpu.skip = true;
    end

END


// 06 - DAA
function op_daa()
// CHECKED
BEGIN

    cpu.acc = ( cpu.acc + 6 ) &0xf;
END


// 07 - TAL
function op_tal()
// CHECKED
BEGIN

    cpu.dpl = cpu.acc;
END


// 08 - AD
function op_ad()
// CHECKED
BEGIN

    cpu.acc += ram_r();

    cpu.skip = (( cpu.acc & 0x10) !=0);

    cpu.acc &= 0xf;

END


// 09 - ADS
function op_ads()
// CHECKED
BEGIN

    op_adc();

    cpu.skip = ( cpu.carry_f !=0);

END


// 0a - DAS
function op_das()
// CHECKED
BEGIN

    cpu.acc = ( cpu.acc + 10 ) &0xf;


END


// 0b - CLC
function op_clc()
// CHECKED
BEGIN

    cpu.carry_f = 0;


END


// 0c - CM
function op_cm()
// CHECKED
BEGIN

    cpu.skip = ( cpu.acc == ram_r());

END


// 0d - INC
function op_inc()
// CHECKED
BEGIN

    cpu.acc = ( cpu.acc + 1 ) & 0xf;

    cpu.skip = ( cpu.acc == 0 );

END


// 0e - OP
function op_op()
// CHECKED
BEGIN

    output_w(cpu.dpl, cpu.acc);

END


// 0f - DEC
function op_dec()
// CHECKED
BEGIN

    cpu.acc = ( cpu.acc - 1 ) & 0xf;

    cpu.skip = ( cpu.acc == 0xf );

END


// 10 - CMA
function op_cma()
// CHECKED
BEGIN

    cpu.acc ^= 0xf;
END


// 11 - CIA
function op_cia()
// CHECKED
BEGIN
    cpu.acc = (( cpu.acc ^ 0xf) +1) &0xf;
END


// 12 - TLA
function op_tla()
// CHECKED
BEGIN

    cpu.acc = cpu.dpl;

END


// 0x13 - DED
function op_ded()
// CHECKED
BEGIN

    cpu.dpl = (cpu.dpl -1) & 0xf;

    cpu.skip = (cpu.dpl == 0xf );

END


// 0x14 - STM
function op_stm()
// CHECKED
BEGIN

    if(!check_op_43())
        return;
    end

    // reset timer flag
    cpu.timer_f = 0;

    // set to now plus however many ticks (should be 2)
    // which will be reduced to n*63 on op return;
    cpu.tc = ((cpu.arg &0x3f) +1)*63 + (cpu.old_icount - cpu.icount);


END


// 15 - LDI X
// LOAD DP with X
function op_ldi()
// CHECKED
BEGIN
    cpu.dph = cpu.arg >> 4 & 0xf;
    cpu.dpl = cpu.arg & 0xf;

END


// 16 - CLI
function op_cli()
// CHECKED
BEGIN

    cpu.skip = ( cpu.dpl == ( cpu.arg & 0xf));

END


// 17 - CI
function op_ci()
// CHECKED
BEGIN

    cpu.skip = ( cpu.acc == (cpu.arg & 0xf) );

END


// 18 - EXL
function op_exl()
// CHECKED
BEGIN

    cpu.acc ^= ram_r();
END


// 19 - ADC
function op_adc()
// CHECKED
BEGIN

    cpu.acc += ram_r() + cpu.carry_f;
    cpu.carry_f = cpu.acc >> 4 & 1;
    cpu.acc &= 0xf;

END


// 1A - XC
function op_xc()
// CHECKED
PRIVATE
BYTE c;

BEGIN
    if(!check_op_43())
        return;
    end

    c = cpu.carry_f;
    cpu.carry_f = cpu.carry_s_f;
    cpu.carry_s_f = c;

END


// 1B - STC
function op_stc()
// CHECKED
BEGIN

    cpu.carry_f = 1;

END


// 1C - ILLEGAL


// 1D - INM
function op_inm()
// CHCKED
PRIVATE
BYTE val;

BEGIN

    if(!check_op_43())
        return;
    end

    val = (ram_r() +1) & 0xf;
    ram_w(val);

    cpu.skip = (val == 0);

END


// 1E - OCD
function op_ocd()
// CHECKED
BEGIN

    output_w(NEC_UCOM4_PORTD, cpu.arg >> 4);
    output_w(NEC_UCOM4_PORTC, cpu.arg & 0xf);
END


// 1F - DEM
function op_dem()
// CHECKED
PRIVATE
BYTE val;

BEGIN
    IF(!check_op_43())
        return;
    END

    val = (ram_r() -1) &0xf;
    ram_w(val);
    cpu.skip = (val == 0xf);

END


// 30 - RAR
function op_rar()
// CHECKED
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
// CHECKED
BEGIN

    cpu.dpl = ( cpu.dpl + 1 ) & 0xf;

    cpu.skip = (cpu.dpl == 0);

END


// 40 - IA
function op_ia()
BEGIN

    DEBUG;
END


// 41 - JPA
function op_jpa()
// CHECKED
BEGIN

    cpu.icount--;
    cpu.pc = (cpu.pc & !0x3F) | (cpu.acc << 2);
END


// 42 - TAZ
function op_taz()
// CHECKED
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.icount--;
    ucom43_reg_w(UCOM43_Z, cpu.acc);

END


// 43 - TAW
function op_taw()
// CHECKED
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.icount--;
    ucom43_reg_w(UCOM43_W, cpu.acc);

END


// 44 - OE
function op_oe()
// CHECKED
BEGIN

    cpu.icount--;
    output_w(NEC_UCOM4_PORTE, cpu.acc);
END


// 45 - ILLEGAL


// 0x46 - TLY
function op_tly()
// CHECKED
BEGIN
    if(!check_op_43())
        return;
    end

    cpu.icount--;
    ucom43_reg_w(UCOM43_Y,cpu.dpl);

END


// 47 - THX
function op_thx()
// CHECKED
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.icount--;
    ucom43_reg_w(UCOM43_X, cpu.dph);

END


// 0x48 - RT
function op_rt()
// CHECKED
BEGIN
    cpu.icount--;
    pop_stack();
END


// 49 - RTS
function op_rts()
// CHECKED
BEGIN
    op_rt();
    cpu.skip = true;
END


// 4A - XAZ
function op_xaz()
// CHECKED
PRIVATE

BYTE old_acc;


BEGIN

    if(!check_op_43())
        return;
    end

    cpu.icount--;
    old_acc = cpu.acc;
    cpu.acc = ucom43_reg_r(UCOM43_Z);
    ucom43_reg_w(UCOM43_Z, old_acc);

END


// 4B - XAW
function op_xaw()
// CHECKED
PRIVATE
BYTE old_acc;

BEGIN

    if(!check_op_43())
        return;
    end

    cpu.icount--;
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
// CHECKED
PRIVATE

BYTE old_dpl;

BEGIN

    if(!check_op_43())
        return;
    end

    cpu.icount--;
    old_dpl = cpu.dpl;
    cpu.dpl = ucom43_reg_r(UCOM43_Y);
    ucom43_reg_w(UCOM43_Y, old_dpl);

END


// 4F - XHX
function op_xhx()
// CHECKED
PRIVATE

BYTE old_dph;

BEGIN

    if(!check_op_43())
        return;
    end

    cpu.icount--;

    old_dph = cpu.dph;
    cpu.dph = ucom43_reg_r(UCOM43_X);
    ucom43_reg_w(UCOM43_X, old_dph);


END



// OPS & 0xFC

// 20 - FBF
function op_fbf()
// CHECKED
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.icount--;


    cpu.skip = ((ucom43_reg_r(UCOM43_F) & cpu.bitmask)==0);


END


// 24 - TAB
function op_tab()
// CHECKED
BEGIN

    cpu.skip = (( cpu.acc & cpu.bitmask) !=0);

END


// 28 - XM  (0x2B)
//
function op_xm()
// CHECKED
PRIVATE
BYTE old_acc;

BEGIN

    old_acc = cpu.acc;
    cpu.acc = ram_r();
    ram_w(old_acc);
    cpu.dph ^= (cpu.op & 0x03);
END


// 2C - XMD
//
function op_xmd()
// CHECKED
BEGIN

    op_xm();
    cpu.dpl = (cpu.dpl -1) & 0xf;

    cpu.skip = (cpu.dpl == 0xf);


END


// 34 - CMB
function op_cmb()
BEGIN

    DEBUG;
END


// 38

function op_lm()
// CHECKED
BEGIN

    cpu.acc = ram_r();
    cpu.dph ^= (cpu.op &0x03);

END


// 3C - XMI
function op_xmi()
// CHECKED
BEGIN

    op_xm();
    cpu.dpl = (cpu.dpl + 1) & 0xf;
    cpu.skip = ( cpu.dpl == 0 );

END


// 50 - TPB
function op_tpb()
// CHECKED
BEGIN

    cpu.skip = (( input_r(cpu.dpl) & cpu.bitmask ) !=0 );
END


// 54 - TPA
function op_tpa()
// CHECKED
BEGIN

    cpu.skip = (( input_r(NEC_UCOM4_PORTA) & cpu.bitmask) !=0);

END


// 58 - TMB
function op_tmb()
// CHECKED
BEGIN

    cpu.skip = ((ram_r() & cpu.bitmask) !=0);

END


// 5C - FBT
function op_fbt()
// CHECKED
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.icount--;
    cpu.skip = (( ucom43_reg_r(UCOM43_F) & cpu.bitmask) !=0);

END

// 60 - RPB
function op_rpb()
BEGIN

    DEBUG;
END



// 64 - REB
function op_reb()
// CHECKED
BEGIN

    cpu.icount--;
    output_w(NEC_UCOM4_PORTE, cpu.port_out[NEC_UCOM4_PORTE] & !cpu.bitmask);

END


// 68 - RMB
function op_rmb()
// CHECKED
BEGIN

    ram_w(ram_r() & !cpu.bitmask);
END


// 6C - RFB
function op_rfb()
// CHECKED
BEGIN

    if(!check_op_43())
        return;
    end

    cpu.icount--;
    ucom43_reg_w(UCOM43_F, ucom43_reg_r(UCOM43_F) & !cpu.bitmask);

END


// 70 - SPB
function op_spb()
BEGIN

    DEBUG;
END


// 74 - SEB
function op_seb()
// CHECKED
BEGIN

    cpu.icount--;
    output_w(NEC_UCOM4_PORTE, cpu.port_out[NEC_UCOM4_PORTE] | cpu.bitmask);

END


// 78 - SMB
function op_smb()
// CHECKED
BEGIN

    ram_w(ram_r() | cpu.bitmask);

END


// 7C - SFB
function op_sfb()
// CHECKED
BEGIN

     if(!check_op_43())
        return;
     end

     cpu.icount--;
     ucom43_reg_w(UCOM43_F, ucom43_reg_r(UCOM43_F) | cpu.bitmask);

END



// 0x80 - LDZ
function op_ldz()
// CHECKED
BEGIN

    cpu.dph = 0;
    cpu.dpl = cpu.op & 0x0f;

END


// 0x90 - LI
function op_li()
// CHECKED
BEGIN

    if((cpu.prev_op & 0xf0) != (cpu.op & 0xf0))
        cpu.acc = cpu.op & 0x0f;
    end

END


// 0xA0 - JMPCAL
function op_jmpcal()
// CHECKED
BEGIN
    if ((cpu.op & 0x08) >0)
        push_stack();
    end

    cpu.pc = (( cpu.op & 0x07) << 8 | cpu.arg) & cpu.prgmask;
END


// 0xB0 - CZP
function op_czp()
// CHECKED
BEGIN
    push_stack();
    cpu.pc = (cpu.op & 0x0f) << 2;
END

// 0xC0 0xD0 0xE0 0xF0 - JCP
function op_jcp()
// CHECKED
BEGIN
    cpu.pc = (cpu.pc & !0x3F) | (cpu.op & 0x3F);

END






function op_jmp()

BEGIN

    DEBUG;

END
