#include "driver.h"
#include "ucom4_cpu.h"

extern vfd_game game_caveman;

void caveman_prepare_display(ucom4cpu *cpu);
void caveman_setup_gfx(void);
void caveman_display_update(void);
void caveman_output_w(ucom4cpu *cpu, int index, uint8_t data);
uint8_t caveman_input_r(ucom4cpu *cpu, int index);
