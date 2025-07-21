
void uart_putc(char c)
{
    volatile char *uart_tx = (char *)0xFFFFFFFC;
    *uart_tx = c;
}
void uart_puts(const char *str)
{
    while (*str)
    {
        uart_putc(*str++);
    }
}

void uart_puthex(unsigned int val)
{
    uart_puts("0x");

    int shift = 28;
    for (int i = 0; i < 8; i++)
    {
        unsigned int nibble = (val >> shift) & 0xF;
        uart_putc(nibble < 10 ? ('0' + nibble) : ('A' + nibble - 10));
        shift -= 4;
    }
    uart_puts("\n");
}
void uart_putsi(const char *str, unsigned int val)
{
    uart_puts(str);
    uart_puthex(val);
}

int looper(int var)
{
    int a, b, d;
    a = 0;
    d = 0;
    b = 0;
    while (d < 5)
    {
        if (d >= 1)
        {
            break;
        }
        for (a = 0; a < 7; a++)
        {
            b = 0;
            while (b < 2)
            {
                var -= 0x1; // decrement each time
                b++;
            }
        }
        d++;
    }
    return var;
}
int main()
{
    int a, b;
    uart_puts("Hello World, from dummy!\n");
    a = 0xE110CAFE;
    uart_putsi("Data initial value:", a);
    b = looper(a);
    uart_putsi("Data final value:", b);
    uart_putsi("Data Correct value:", (a - 14));
    return 0;
}
