/* Define base addresses */
IMEM_BASE = 0x00000000;
DMEM_BASE = 0x10000000;
ENTRY(_start)

MEMORY
{
  IMEM (rx) : ORIGIN = IMEM_BASE, LENGTH = 64K
  DMEM (rw) : ORIGIN = DMEM_BASE, LENGTH = 16K
}

SECTIONS
{
  . = 0x0000000;
    .text : {
        *(.text.start)
        *(.text .text.*)
    }> IMEM

  .data : {
    *(.data*)
    *(.rodata*)
  } > DMEM

  .bss : {
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
} > DMEM

}