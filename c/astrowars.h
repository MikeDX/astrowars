#include "driver.h"
#include "ucom4_cpu.h"

extern vfd_game game_astrowars;

void astrowars_prepare_display(ucom4cpu *cpu);
void astrowars_setup_gfx(void);
void astrowars_display_update(void);
void astrowars_output_w(ucom4cpu *cpu, int index, uint8_t data);
uint8_t astrowars_input_r(ucom4cpu *cpu, int index);
