#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vimm.h"

#define MAX_SIM_TIME 9
vluint64_t sim_time = 0;

int inst[] = {
    0b000000000000000000001000000010111,
    0b000000000000000000001000000110111,
    0b000000000000000000001000001100011,
    0b000000000000000000001000001101111,
    0b000000000000000000001000001100111,
    0b000000000000000000001000000000011,
    0b000000000000000000001000000100011,
    0b000000000000000000001000000010011,
    0b000000000000000000001000001001111
};

int main(int argc, char** argv, char** env) {
    Vimm *dut = new Vimm;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");
    int i = 0;
    while (sim_time < MAX_SIM_TIME) {
        dut->inst = inst[i++];
        dut->eval();
        std::cout << dut->out << std::endl;
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}