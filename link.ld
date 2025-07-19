/* Define base addresses */
IMEM_BASE = 0x00000000;
DMEM_BASE = 0x10000000;
ENTRY(_start)

MEMORY
{
  IMEM (rx) : ORIGIN = IMEM_BASE, LENGTH = 4K
  DMEM (rw) : ORIGIN = DMEM_BASE, LENGTH = 4K
}

SECTIONS
{
  .text : {
    *(.text*)
  } > IMEM

  .data : {
    *(.data*)
    *(.rodata*)
  } > DMEM

  .bss : {
    *(.bss*)
    *(COMMON)
  } > DMEM

}
