SIM ?= verilator
TOPLEVEL_LANG ?= verilog
WAVES = 1
VERILOG_SOURCES += $(PWD)/*.sv
EXTRA_ARGS += --trace --trace-structs --timing -j 0

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = TB

# MODULE is the basename of the Python test file
MODULE = test
all: compile sim

compile:
		riscv32-unknown-elf-gcc -nostdlib -O0 -march=rv32i -mabi=ilp32 -T link.ld -o test.elf test.s
		riscv32-unknown-elf-objdump -D test.elf > test.dump
		riscv32-unknown-elf-elf2hex --bit-width 32 --input test.elf >code.mem
sim:
include $(shell cocotb-config --makefiles)/Makefile.sim


