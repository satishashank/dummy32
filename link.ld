ENTRY(_start)

SECTIONS {
  /* Set the base address to 0 */
  . = 0x00000000;

  /* Code section */
  .text : {
    *(.text*)  /* Match all .text sections from all object files */
  }
}
