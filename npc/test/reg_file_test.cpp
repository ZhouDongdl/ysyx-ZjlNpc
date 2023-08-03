#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vreg_file.h"

#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;

int A[3] = {
    0b10101,
    0b10111,
    0b10111
};

int main(int argc, char** argv, char** env) {
    Vreg_file *dut = new Vreg_file;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("reg_file.vcd");
    dut->WE = 1;
    dut->clk = 1;
    dut->A1 = A[0], dut->A2 = A[1], dut->A3 = A[2];
    dut->WD = 0xe;
    while (sim_time < MAX_SIM_TIME) {
        dut->clk = !dut->clk;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}