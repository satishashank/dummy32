// // #include <stdint.h>

// // ------------------------
// // UART functions
// // ------------------------
// #define UART_TX (*(volatile char *)0xFFFFFFFC)
// #define UART_STATUS (*(volatile char *)0xFFFFFFF8)

// void uart_putc(char c)
// {
//     // wait until TX FIFO not full
//     while (UART_STATUS & 0x1)
//     {
//         // spin
//     }
//     UART_TX = c;
// }

// void uart_puts(const char *str)
// {
//     while (*str)
//     {
//         uart_putc(*str++);
//     }
// }
// void uart_puthex(unsigned int val)
// {
//     uart_puts("0x");

//     int shift = 28;
//     for (int i = 0; i < 8; i++)
//     {
//         unsigned int nibble = (val >> shift) & 0xF;
//         uart_putc(nibble < 10 ? ('0' + nibble) : ('A' + nibble - 10));
//         shift -= 4;
//     }
// }
// void uart_putsh(const char *str, int val)
// {
//     uart_puts(str);
//     uart_puthex(val);
// }

// // // ------------------------
// // // Recursive example (addition only factorial)
// // // ------------------------
// // int factorial_add(int n)
// // {
// //     if (n <= 1)
// //         return 1;

// //     // compute n * factorial(n-1) using repeated addition
// //     int f = factorial_add(n - 1);
// //     int result = 0;
// //     for (int i = 0; i < n; i++)
// //     {
// //         result += f;
// //     }
// //     return result;
// // }
// int func(int sum)
// {
//     int i = 4;
//     return sum + i;
// };
// // ------------------------
// // Main
// // ------------------------
int main(void)
{
    int i, j, sum = 0;
    for (i = 0; i < 10; i++)
    {
        sum = sum + i;
    }

    return 0;
}
