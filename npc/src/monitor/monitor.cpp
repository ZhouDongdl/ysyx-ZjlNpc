#include <common.h>
#include <paddr.h>
#include <vaddr.h>
#include <getopt.h>
#include <debug.h>

void init_mem();
void init_sdb();
void sdb_set_batch_mode();
void restart();
void init_difftest(char *ref_so_file, long img_size, int port);


char *img_file = NULL;
static char *log_file = NULL;
static char *diff_so_file = NULL;
static int difftest_port = 1234;

static const uint32_t img [] = {
  0x00000297,  // auipc t0,0
  0x0002b823,  // sd  zero,16(t0)
  0x0102b503,  // ld  a0,16(t0)
  0x00100073,  // ebreak (used as nemu_trap)
  0xdeadbeef,  // some data
};

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch"    , no_argument      , NULL, 'b'},
    {"log"      , required_argument, NULL, 'l'},
    {"diff"     , required_argument, NULL, 'd'},
    {"port"     , required_argument, NULL, 'p'},
    {"help"     , no_argument      , NULL, 'h'},
    {0          , 0                , NULL,  0 },
  };
  int o;
  while ( (o = getopt_long(argc, argv, "-bhl:d:p:", table, NULL)) != -1) {
    switch (o) {
      case 'b': sdb_set_batch_mode(); break;
      case 'p': sscanf(optarg, "%d", &difftest_port); break;
      case 'l': log_file = optarg; break;
      case 'd': diff_so_file = optarg; break;
      case 1: img_file = optarg; return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-l,--log=FILE           output log to FILE\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\t-p,--port=PORT          run DiffTest with port PORT\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}

static long load_img() {
  if (img_file == NULL) {
    memcpy(guest_to_host(RESET_VECTOR), img, sizeof(img));
    return 4096; // built-in image size
  }

  FILE *fp = fopen(img_file, "rb");
  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  fseek(fp, 0, SEEK_SET);
  int ret = fread(guest_to_host(RESET_VECTOR), size, 1, fp);
  assert(ret == 1);

  fclose(fp);
  return size;
}

static void welcome() {
  printf("-------------------------------------\n");
  Log("Build time: %s, %s", __TIME__, __DATE__);
  printf(ANSI_FMT("Welcome to RISCV64-NPC!\n", ANSI_FG_YELLOW));
  printf("For help, type \"help\"\n");
}

void init_monitor(int argc, char *argv[]) {
  /* Perform some global initialization. */

  /* Parse arguments. */
  parse_args(argc, argv);

  /* Initialize memory. */
  init_mem();

  /* Load the image to memory. This will overwrite the built-in image. */
  long img_size = load_img();

  /* Initialize the simple debugger. */
  // init_sdb();

  /* Initialize verilog wave trace */
  restart();
  
  /* Initialize differential testing. */
  // init_difftest(diff_so_file, img_size, difftest_port);
  
  /* Display welcome message. */
  welcome();
  // for (int i = 0; i < img_size; i += 4) printf("%08x\n", vaddr_read(RESET_VECTOR + i, 4));
}