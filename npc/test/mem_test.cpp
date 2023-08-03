#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vmem.h"
#include "svdpi.h"
#include "Vmem__Dpi.h"

#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;

long long read_mem(long long addr, int len) {
    return (long long)1 + len;
}

int get_inst(long long addr) {
    return 1;
}

int mem[100] = {};

void write_mem(long long addr, int len) {
    mem[addr] = len;
}

int main(int argc, char** argv, char** env) {
    Vmem *dut = new Vmem;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("storage.vcd");
    dut->clk = 1;
    dut->im_addr = 0;
    dut->dm_addr = 2;
    while (sim_time < MAX_SIM_TIME) {
        dut->clk ^= 1;
        dut->im_addr ++;
        std::cout << 1 << ' ' << mem[dut->dm_addr] << '\n';
        dut->eval();
        std::cout << 2 << ' '  << mem[dut->dm_addr] << ' ' << dut->im_dout << '\n';
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}