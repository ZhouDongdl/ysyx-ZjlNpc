#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vctrl.h"

#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;

uint32_t inst[] = {
    0x00009117,
    0xffc10113,
    0x00c000ef
};
int i = 0;

int main(int argc, char** argv, char** env) {
    Vctrl *dut = new Vctrl;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("ctrl.vcd");
    while (sim_time < MAX_SIM_TIME) {
        dut->inst = inst[i++];
        if (i == 3) i = 0;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}