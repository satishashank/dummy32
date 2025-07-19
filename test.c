
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
int recursive(int x, int y, int var)
{
    // Subracts 14 one by one
    if (x > (y - 1))
    {
        return var;
    }
    else
    {
        x = x + 1;
        var = var - 1;
        recursive(x, y, var);
    }
}
int main()
{
    uart_puts("Hello, world From dummy!\n");
    int a, b, c;
    a = 0xBEEFCAFE;
    recursive(0, 14, a);
    uart_puts("Recursion Complete.\n");
    return 0;
}
