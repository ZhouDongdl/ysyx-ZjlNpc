#ifndef __CPU_CPU_H__
#define __CPU_CPU_H__

#include <common.h>

typedef struct {
  word_t gpr[32];
  vaddr_t pc;
} CPU_state;

extern CPU_state n_cpu;

void n_cpu_exec(uint64_t n);

void set_npc_state(int state, vaddr_t pc, int halt_ret);
void invalid_inst(vaddr_t thispc);

#define NPCTRAP(thispc, code) set_npc_state(NPC_END, thispc, code)
#define INV(thispc) invalid_inst(thispc)

#endif