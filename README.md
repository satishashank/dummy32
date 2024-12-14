# dummy32

## How to use

Just run `make` and the processor processes the instructions available to it via the `mem_read` line.
The `core.fst` is the waveform file in the `sim_build` folder. 

## Editing Instructions

Instructions are a list of hex values in the test.py.

## Regesters

Registers are initialized by the `$readmemh` instruction and are loaded into `registerFile`.