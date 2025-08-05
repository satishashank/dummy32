# dummy32

A 5-stage pipelined RV32I core started as a block diagram from *"Digital Design & Computer Architecture: RISC-V Edition"*, enhanced with full RV32I support and dynamic branch prediction.

## Features

* Passes all [riscv-tests](https://github.com/riscv/riscv-tests) for RV32I

* Runs [benchmark-dhrystone](https://github.com/sifive/benchmark-dhrystone)

* Dynamic branch prediction using a Branch Target Buffer (BTB) with 2-bit saturating counters

* Branch predictor can be turned off in the testbench for before and after

* Hazard handling with register forwarding and pipeline stalls

  
Impact of branch prediction on `benchmark-dhrystone` with `500` iterations and "always-taken" as base:
<p align="center">
<img width="420" height="320" alt="Btb" src="https://github.com/user-attachments/assets/b5da3240-2326-479a-ac0c-c65d42c747dd" />
</p>




## Prerequisites:
The core is simulated using open-source tools which include:
[Verilator](), [CoCoTB](https://github.com/cocotb/cocotb).
However, the `Vivado Suite` was used for final linting and synthesizability.

The C/asm files to be run are compiled using the standard [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) with a custom linking script seperating data and code. The generated `elf` is *"hexdumped"* to `code.mem` and `data.mem` [hexdump](https://man7.org/linux/man-pages/man1/hexdump.1.html).

## Simulation and executing C on the core
As mentioned, a combination of `Verilator` and `CoCoTB` is used for simulation, debugging, and logging. The core copies the generated `code.mem` to the instruction memory for execution, and the `Makefile` streamlines this process.

To compile C, and generating .mem files for verilog run:

    make code.mem

    make data.mem

This command compiles the `test.c` file along with a basic startup file `boot.s` using the linker script.
`boot.s` initializes the stack pointer `sp` (or `x2`) and calls `main`.

Simulation, along with generating the hex dump for the memories, can be run using:

    make

The writes to the registers and the addresses, along with the `PC` values, are dumped to the terminal while `simUart` logs out characters from C.

The included C file executes loops and recursions to check the stack and the prediction mechanism. You should see this output on a successful run:

    Hello World, from dummy!
    Data initial value:0xE110CAFE
    Data final value:0xE110CAF0
    Data Correct value:0xE110CAF0

## Running `riscv-tests`

From `./riscv-tests `

    make


this replaces the  `rv32i_test.elf` which is your new executable. This is now `hexdumped` as usual from the root directory's `Makefile` as:

From `./`

    make
If the tests pass u should see the following output:

    add..ok
    addi..ok
    xor..ok
    ...
    sw..ok
In case of failure:

    ...
    add..error
    ...

## Running benchmark-dhrystone 
The `dhrystone` folder is ported from `benchmark-dhrystone` and uses newly defined `__mulsi3` and `__divsi3` function to not use double-floating point precision. 
 
Similar to `riscv-tests` running `make` inside the `dhrystone` folder dumps out the `elf` in the root folder. 

The test uses cycle count instead of time since this a simulation enviornment. This is done using a memory-mapped counter `cycleCounter` which is turned ON from a specifc write of `0xAFA51A91` at` 0xFFFFFFF4`. The C code uses function `start_timer`, `stop-timer`and `read-timer` for easy-use (see `dhry.h`).

Number of iterations can be changed from the C code and defaults to `500`. The minimum number of clock cycles to log out cycle count is kept at `1000`.
