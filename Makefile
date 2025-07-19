SIM ?= verilator
TOPLEVEL_LANG ?= verilog
WAVES = 1
VERILOG_SOURCES += $(PWD)/rtl/*.sv
EXTRA_ARGS += --trace --trace-structs --timing -j 8
.PHONY: all clean sim

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = TB

# MODULE is the basename of the Python test file
MODULE = test
all: sim code.mem data.mem code.dump


code.elf: link.ld boot.s test.c
		riscv32-unknown-elf-gcc -nostdlib -nostartfiles -O0 -march=rv32i -mabi=ilp32 -T link.ld boot.s test.c -o code.elf
code.dump: code.elf
		riscv32-unknown-elf-objdump -D code.elf > code.dump
data.bin: code.elf
		riscv32-unknown-elf-objcopy -O binary --only-section=.data code.elf data.bin
code.bin: code.elf
		riscv32-unknown-elf-objcopy -O binary --only-section=.text code.elf code.bin
code.mem: code.bin
		hexdump -v -e '1/4 "%08x\n"' code.bin >code.mem
data.mem: data.bin
		hexdump -v -e '1/1 "%04x\n"' data.bin > data.mem
sim: code.mem data.mem
include $(shell cocotb-config --makefiles)/Makefile.sim
clean::
	rm -rf code* data* results.xml

