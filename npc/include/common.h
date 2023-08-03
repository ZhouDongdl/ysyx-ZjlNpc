#ifndef __COMMON_H__
#define __COMMON_H__

#include <stdint.h>
#include <inttypes.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>

#include "macro.h"
#include "v_sim.h"

typedef uint64_t word_t;
typedef int64_t  sword_t;
#define FMT_WORD "0x%016"PRIx64
#define FMT_PADDR "0x%016"PRIx64

typedef word_t vaddr_t;
typedef uint64_t paddr_t;

extern Vtop *dut;
extern VerilatedVcdC *m_trace;

#endif
