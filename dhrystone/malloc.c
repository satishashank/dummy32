#include <stdint.h>

extern char __bss_end[];

static uint32_t *stack_ptr = (uint32_t *)0x1000FFFC;
static uint32_t *heap_ptr = (uint32_t *)__bss_end;

void *
malloc(unsigned int size)
{
    // Align size to 4 bytes
    size = (size + 3) & ~3;

    // Check for heap-stack collision
    if (heap_ptr + size >= stack_ptr)
    {
        return 0; // Out of memory
    }

    void *ptr = heap_ptr;
    heap_ptr += size;
    return ptr;
}
