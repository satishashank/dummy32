SIM ?= verilator
TOPLEVEL_LANG ?= verilog
WAVES = 1
VERILOG_SOURCES += $(PWD)/*.sv
EXTRA_ARGS += --trace --trace-structs --timing -j 0
COMPILE_ARGS += -j 0

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = TB

# MODULE is the basename of the Python test file
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim