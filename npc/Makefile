TOPNAME := top
INC_PATH := $(abspath ./include) $(abspath ./include/memory)

DIFF_REF_PATH = $(NEMU_HOME)
DIFF_REF = riscv64-nemu-interpreter-so
DIFF_REF_SO = $(DIFF_REF_PATH)/build/$(DIFF_REF)
REFFLAGS = GUEST_ISA=riscv64 SHARE=1 ENGINE=interpreter -lreadline
ARGS_DIFF = --diff=$(DIFF_REF_SO)

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert \
				--trace

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))


# project source
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./src) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
LDFLAGS += -l:$(DIFF_REF) -L$(DIFF_REF_PATH)/build -Wl,-rpath=$(DIFF_REF_PATH)/build -lreadline

override ARGS ?= --log=$(BUILD_DIR)/npc-log.txt

IMG ?=
NPC_EXEC := $(BIN) $(ARGS) $(ARGS_DIFF) $(IMG)

NEMU_FILE := $(shell find $(abspath ../nemu/src) -name "*.c")
$(DIFF_REF_SO): $(NEMU_FILE)
	@$(MAKE) -s -C $(DIFF_REF_PATH) $(REFFLAGS)

$(BIN): $(VSRCS) $(CSRCS) $(DIFF_REF_SO)
	@rm -rf $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $(VSRCS) $(CSRCS) \
		$(addprefix -CFLAGS , $(CFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all: default

run: $(BIN)
	@$(call git_commit, "run NPC")
	@$(NPC_EXEC)

clean:
	rm -rf $(BUILD_DIR)
	rm -f waveform.vcd

.PHONY: default all clean run