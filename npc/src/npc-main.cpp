#include<utils.h>

void init_monitor(int, char *[]);
void sdb_mainloop();

int main(int argc, char *argv[]) {
  /* Initialize the monitor. */
  init_monitor(argc, argv);

  /* Start engine. */
  sdb_mainloop();

  m_trace->close();
  delete dut;
  return is_exit_status_bad();
}