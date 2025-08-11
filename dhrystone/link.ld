IMEM_BASE = 0x00000000;
DMEM_BASE = 0x10000000;

ENTRY(_start)

MEMORY
{
  IMEM (rx) : ORIGIN = IMEM_BASE, LENGTH = 64K
  DMEM (rw) : ORIGIN = DMEM_BASE, LENGTH = 64K
}

SECTIONS
{
  /* Code in IMEM */
  .text : {
    *(.text.start)
    *(.text .text.*)
  } > IMEM

  /* Data in DMEM */
  . = ORIGIN(DMEM);

  .data  : {
      __data_start = .;
      *(.data*)
      *(.rodata*)
      __data_end = .;
  } > DMEM

  .sdata : {
      __sdata_start = .;
      *(.sdata*)
      __sdata_end = .;
  } > DMEM

  .sbss : {
      __sbss_start = .;
      *(.sbss*)
      __sbss_end = .;
  } > DMEM

  .bss   : {
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
  } > DMEM

  /* Define heap and stack boundaries */
}
