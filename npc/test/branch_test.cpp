#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vbranch.h"
//see the result in wave file
#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;

int type[] = {
    0b010,
    0b011,
    0b100,
    0b101,
    0b110,
    0b111,
    0b000
};

int main(int argc, char** argv, char** env) {
    Vbranch *dut = new Vbranch;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("branch.vcd");
    int i = 0;
    dut->REG1 = 1, dut->REG2 = 2;
    while (sim_time < MAX_SIM_TIME) {
        dut->Type = type[i++];
        if (i == 8) i = 0;
        dut->eval();
        std::cout<< (int)dut->BrE << std::endl;
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}