#include <stdint.h>

// ------------------------
// Software multiply/divide (RV32I-friendly)
// ------------------------
int __divsi3(int a, int b)
{
    if (b == 0)
        return 0; // avoid div by zero

    int quot = 0;
    int sign = 1;

    if (a < 0)
    {
        a = -a;
        sign = -sign;
    }
    if (b < 0)
    {
        b = -b;
        sign = -sign;
    }

    while (a >= b)
    {
        a -= b;
        quot++;
    }
    return sign * quot;
}
unsigned __umodsi3(unsigned a, unsigned b)
{
    if (b == 0)
        return 0; // avoid div by zero
    while (a >= b)
    {
        a -= b;
    }
    return a;
}

int __mulsi3(int a, int b)
{
    unsigned ua = (a < 0) ? (unsigned)(~a + 1) : (unsigned)a;
    unsigned ub = (b < 0) ? (unsigned)(~b + 1) : (unsigned)b;
    unsigned ur = 0;

    while (ub)
    {
        if (ub & 1)
            ur += ua;
        ua <<= 1;
        ub >>= 1;
    }

    if ((a < 0) ^ (b < 0))
        ur = ~ur + 1;

    return (int)ur;
}

// ------------------------
// UART functions
// ------------------------
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

void uart_puthex(uint32_t val)
{
    uart_puts("0x");

    int shift = 28;
    for (int i = 0; i < 8; i++)
    {
        uint32_t nibble = (val >> shift) & 0xF;
        uart_putc(nibble < 10 ? ('0' + nibble) : ('A' + nibble - 10));
        shift -= 4;
    }
}

void uart_putint(uint32_t val)
{
    char buf[11]; // max 10 digits + null
    int i = 0;

    if (val == 0)
    {
        uart_putc('0');
        return;
    }

    while (val > 0)
    {
        uint32_t digit = __umodsi3(val, 10);
        buf[i++] = '0' + digit;
        val = __divsi3(val, 10);
    }

    while (i > 0)
    {
        uart_putc(buf[--i]);
    }
}

void uart_putsi(const char *str, uint32_t val)
{
    uart_puts(str);
    uart_puthex(val);
    uart_putc('\n');
}
// ------------------------
// Benchmark globals & helpers
// ------------------------
volatile uint32_t sink = 0;

static inline uint32_t xorshift32(uint32_t *state)
{
    uint32_t x = *state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    *state = x;
    return x;
}

// ------------------------
// Branch pattern functions
// ------------------------
void always_taken(uint32_t loops)
{
    volatile int cond = 1;
    for (uint32_t i = 0; i < loops; i++)
    {
        if (cond)
            sink++;
    }
}

void always_not_taken(uint32_t loops)
{
    volatile int cond = 0;
    for (uint32_t i = 0; i < loops; i++)
    {
        if (cond)
            sink++;
    }
}

void alternating(uint32_t loops)
{
    uint32_t cond = 0;
    for (uint32_t i = 0; i < loops; i++)
    {
        if (cond)
            sink++;
        cond ^= 1;
    }
}

void periodic(uint32_t loops, uint32_t period)
{
    uint32_t state = 0;
    uint32_t half = period >> 1;
    for (uint32_t i = 0; i < loops; i++)
    {
        if (state < half)
            sink++;
        state++;
        if (state >= period)
            state = 0;
    }
}

void random_branches(uint32_t loops, uint32_t threshold)
{
    uint32_t state = 0x12345678;
    for (uint32_t i = 0; i < loops; i++)
    {
        if (xorshift32(&state) <= threshold)
            sink++;
    }
}

void correlated(uint32_t loops)
{
    uint32_t history = 0;
    for (uint32_t i = 0; i < loops; i++)
    {
        if (history)
        {
            sink++;
            history = ((i & 7) != 0);
        }
        else
        {
            if ((i & 0xF) == 0)
            {
                sink++;
                history = 1;
            }
        }
    }
}

void nested_branches(uint32_t loops)
{
    for (uint32_t i = 0; i < loops; i++)
    {
        if ((i & 3) == 0)
        {
            if ((i & 7) == 0)
                sink++;
        }
        else
        {
            if (i & 1)
                sink++;
        }
    }
}

void short_loops(uint32_t outer_loops, uint32_t max_trip)
{
    for (uint32_t i = 0; i < outer_loops; i++)
    {
        uint32_t trips = __divsi3(i, max_trip);
        trips = i - __mulsi3(trips, max_trip); // trips = i % max_trip
        trips = trips + 1;
        for (uint32_t t = 0; t < trips; t++)
        {
            sink++;
        }
    }
}

void long_loop(uint32_t outer_loops, uint32_t trips)
{
    for (uint32_t i = 0; i < outer_loops; i++)
    {
        for (uint32_t t = 0; t < trips; t++)
        {
            sink++;
        }
    }
}
uint32_t factorial_recursive(uint32_t n)
{
    if (n <= 1)
        return 1;
    return __mulsi3(n, factorial_recursive(n - 1));
}

// ------------------------
// Main
// ------------------------
int main(void)
{
    uint32_t loops = 200; // adjust for runtime on your core

    uart_puts("Branch predictor test (RV32I)\n");
    uint32_t wrongBranches0, controlXfer0, timer0, wrongBranches1, controlXfer1, N_instructions0, N_instructions1, timer1, User_Cycles;
    asm volatile("csrr %0, 0x80" : "=r"(wrongBranches0));
    asm volatile("csrr %0, 0x81" : "=r"(controlXfer0));
    asm volatile("csrr %0, 0x82" : "=r"(N_instructions0));
    asm volatile("csrr %0, 0x83" : "=r"(timer0));
    always_taken(loops);

    always_not_taken(loops);

    alternating(loops);

    periodic(loops, 3);

    periodic(loops, 8);

    random_branches(loops, 0x80000000u); // 50%

    random_branches(loops, 0x028F5C28u); // ~1%

    correlated(loops);

    nested_branches(loops);

    short_loops(__divsi3(loops, 100), 16);

    long_loop(__divsi3(loops, 1000), 1024);

    uint32_t fact_res = factorial_recursive(__divsi3(loops, 20));

    asm volatile("csrr %0, 0x80" : "=r"(wrongBranches1));
    asm volatile("csrr %0, 0x81" : "=r"(controlXfer1));
    asm volatile("csrr %0, 0x82" : "=r"(N_instructions1));
    asm volatile("csrr %0, 0x83" : "=r"(timer1));
    // Differences
    User_Cycles = timer1 - timer0;
    uint32_t wrongBranches = wrongBranches1 - wrongBranches0;
    uint32_t controlXfers = controlXfer1 - controlXfer0;
    uint32_t instructions = N_instructions1 - N_instructions0;

    // CPI * 1000 (fixed point, 3 decimal places)
    uint32_t cpi_times_1000 = __divsi3(__mulsi3(User_Cycles, 1000), instructions);

    // Misprediction rate * 1000 (fixed point, 3 decimal places)
    uint32_t miss_times_1000 = 0;
    if (controlXfers != 0)
        miss_times_1000 = __divsi3(__mulsi3(wrongBranches, 1000), controlXfers);

    // Print table in decimal
    uart_puts("Total Cycles (dec):        ");
    uart_putint(User_Cycles);
    uart_putc('\n');
    uart_puts("Number of Control Xfers:   ");
    uart_putint(controlXfers);
    uart_putc('\n');
    uart_puts("Number of Instructions:    ");
    uart_putint(instructions);
    uart_putc('\n');
    uart_puts("Wrong Branches:            ");
    uart_putint(wrongBranches);
    uart_putc('\n');

    uart_puts("CPI:                       ");
    uart_putint(__divsi3(cpi_times_1000, 1000)); // integer part
    uart_putc('.');
    uint32_t cpi_frac = __umodsi3(cpi_times_1000, 1000);
    if (cpi_frac < 100)
        uart_putc('0');
    if (cpi_frac < 10)
        uart_putc('0');
    uart_putint(cpi_frac);
    uart_putc('\n');

    uart_puts("Misprediction Rate (%):    ");
    uart_putint(__divsi3(miss_times_1000, 10)); // integer part in %
    uart_putc('.');
    uint32_t miss_frac = __umodsi3(miss_times_1000, 10);
    uart_putint(miss_frac);
    uart_putc('\n');

    uart_puts("Final sink:                ");
    uart_putint(sink);
    uart_putc('\n');
    uart_puts("Done.\n");
    return 0;
}