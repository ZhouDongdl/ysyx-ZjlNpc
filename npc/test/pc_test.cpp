#include <stdlib.h>
#include <iostream>
#include <string>
#include <vector>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vpc.h"
//see the result in wave file
#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;

std::vector<std::string> signal = {
    "rst",
    "aa",
    "jump",
    "bb",
    "jump",
    "aa",
    "jump",
    "bb",
    "jump"
};
int i = 0;

int main(int argc, char** argv, char** env) {
    Vpc *dut = new Vpc;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("pc.vcd");
    dut->clk = 0;
    dut->JUMP_PC = 0x87;
    while (sim_time < MAX_SIM_TIME) {
        dut->clk ^= 1;
        dut->rst = signal[i] == "rst" ? 1 : 0;
        dut->JUMP = signal[i] == "jump" ? 1 : 0;
        if (i++ == 8) i = 0;
        dut->eval();
        std::cout<< (uint32_t)dut->PC << std::endl;
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}