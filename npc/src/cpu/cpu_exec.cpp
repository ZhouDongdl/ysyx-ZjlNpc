#include <memory/paddr.h>
#include <memory/vaddr.h>
#include <debug.h>
#include <utils.h>
#include <cpu.h>
#include <reg.h>

#define R(i) gpr(i)

CPU_state n_cpu = {};
static uint64_t g_timer = 0; // unit: us
uint64_t g_nr_guest_inst = 0;
vaddr_t pre_pc = 0;

Vtop *dut;
VerilatedVcdC *m_trace;
vluint64_t sim_time = 0;
static int istrap = 0;
static int isinv = 0;
char logbuf[128];
uint32_t inst;
uint64_t pc;

// void difftest_step(vaddr_t pc, vaddr_t npc);
void isa_reg_display();

int get_inst(long long addr) {
  inst = vaddr_read(addr, 4);
  return inst;
}
// int i = 0;
long long read_mem(long long addr, int len) {
  // printf("%d\t" FMT_PADDR  "\t" FMT_WORD "\n", i ++, pre_pc, addr);
  return vaddr_read(addr, len);
}

void write_mem(long long addr, int len, long long data) {
  vaddr_write(addr, len, data);
}

void update_regs(int idx, long long data) {
  R(idx) = data;
}

void set_npctrap(int i) {
  if (i) istrap = 1;
  else istrap = 0;
}

void set_npcinv(int i) {
  if (i) isinv = 1;
  else isinv = 0;
}

static void n_trace_and_difftest(vaddr_t pc, vaddr_t dnpc) {
// #ifdef CONFIG_ITRACE_COND
//   if (ITRACE_COND) { log_write("%s\n", _this->logbuf); }
// #endif
  // if (g_print_step) { IFDEF(CONFIG_ITRACE, puts(_this->logbuf)); }
  // difftest_step(pc, dnpc);
}

static void n_isa_exec_once() {
  for (int i = 0; i < 2; ++i) {
    dut->clk ^= 1;
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;
  }

  if (istrap) {
    NPCTRAP(n_cpu.pc, R(10));
  }

  if (isinv) {
    INV(n_cpu.pc);
  }

}

static void n_exec_once() {
  pre_pc = n_cpu.pc;
  n_isa_exec_once();
  n_cpu.pc = dut->pc_cur;
}

static void n_execute(uint64_t n) {

  for (;n > 0; n --) {
    n_exec_once();
    // n_trace_and_difftest(pre_pc, n_cpu.pc);
    g_nr_guest_inst ++;
    if (npc_state.state != NPC_RUNNING) break;
  }
}

static void statistic() {
  IFNDEF(CONFIG_TARGET_AM, setlocale(LC_NUMERIC, ""));
#define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (g_timer > 0) Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else Log("Finish running in less than 1 us and can not calculate the simulation frequency");
}

void assert_fail_msg() {
  isa_reg_display();
  statistic();
} 

/* Simulate how the CPU works. */
void n_cpu_exec(uint64_t n) {
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }

  uint64_t timer_start = get_time();

  n_execute(n);

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (npc_state.state) {
    case NPC_RUNNING: npc_state.state = NPC_STOP; break;

    case NPC_END: case NPC_ABORT:
      Log("npc: %s at pc = " FMT_WORD,
          (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          npc_state.halt_pc);
      // fall through
    case NPC_QUIT: statistic();
  }
}
