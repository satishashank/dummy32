# dummy32
A 5-stage pipelined RV32I core largely based on the book: *"Digital Design & Computer Architecture RISC-V Edition"*, with a dynamic branch predictor for increased throughput.

The predictor is a Branch Target Buffer with a 2-bit saturating counter to keep track of and predict branches.

## Prerequisites:
The core is simulated using open-source tools which include:
[Verilator](), [CoCoTB](https://github.com/cocotb/cocotb).
However, the `Vivado Suite` was used for final linting and synthesizability.

The C file is compiled using the standard [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) with a custom linking script seperating data and code. The generated `elf` is *"hexdumped"* to `code.mem` and `data.mem` [hexdump](https://man7.org/linux/man-pages/man1/hexdump.1.html).

## Simulation and executing C on the core
As mentioned, a combination of `Verilator` and `CoCoTB` is used for simulation, debugging, and logging. The core copies the generated `code.mem` to the instruction memory for execution, and the `Makefile` streamlines this process.

To compile C, and generating .mem files for verilog run:

    make code.mem

    make data.mem

This command compiles the `test.c` file along with a basic startup file `boot.s` using the linker script.
`boot.s` initializes the stack pointer `sp` (or `x2`) and calls `main`.

Simulation, along with generating the hex dump for the instruction memory, can be run using:

    make

The writes to the registers and the addresses, along with the `PC` values, are dumped to the terminal.

Testbench also has a uart-like logger function to log out strings from C.