#ifndef __REG_H__
#define __REG_H__

#include <common.h>

static inline int check_reg_idx(int idx) {
  assert(idx >= 0 && idx < 32);
  return idx;
}

#define gpr(idx) (n_cpu.gpr[check_reg_idx(idx)])

#endif