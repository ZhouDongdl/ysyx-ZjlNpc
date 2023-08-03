#ifndef _V_SIM_H__
#define _V_SIM_H__

#include <Vtop.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <Vtop__Dpi.h>
#include <svdpi.h>

extern Vtop *dut;
extern VerilatedVcdC *m_trace;

int get_inst(long long addr);
long long read_mem(long long addr, int len);
void write_mem(long long addr, int len, long long date);
void update_regs(int idx, long long data);
#endif