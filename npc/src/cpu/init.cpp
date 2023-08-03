#include <cpu.h>
#include <memory/paddr.h>

extern CPU_state n_cpu;

void init_cpu() {
  /* Set the initial program counter. */
  n_cpu.pc = RESET_VECTOR;

  /* The zero register is always 0. */
  n_cpu.gpr[0] = 0;
}

void init_vtop() {
  Verilated::traceEverOn(true);
  dut = new Vtop;
  m_trace = new VerilatedVcdC;
  dut->trace(m_trace, 5);
  dut->clk = 0;
  dut->rst = 0;
  m_trace->open("waveform.vcd");
}

void restart() {
    init_cpu();
    init_vtop();
}