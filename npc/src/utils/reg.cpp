#include <reg.h>
#include <cpu.h>

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void isa_reg_display() {
  int i;
  for (i = 0; i < 32; ++i) {
    uint32_t* p = (uint32_t*)(n_cpu.gpr + i);
    printf("%-8s", regs[i]);
    printf("0x%08x\t", *(p + 1));
    printf("%08x\n", *p);
  }
}

word_t isa_reg_str2val(const char *s, bool *success) {
  int i;
  for (i = 0; i < 32; ++i) {
    if (!strcmp(s, regs[i])) {
      word_t ret = n_cpu.gpr[i];
      *success = true;
      return ret;
    }
  }
  *success = false;
  return 0;
}
