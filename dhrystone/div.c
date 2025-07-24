int __divsi3(int a, int b)
{
    if (b == 0)
        return 0; // Handle division by zero
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
int __mulsi3(int a, int b)
{
    // Convert to unsigned, tracking sign as a boolean(2's complement):
    unsigned ua = (a < 0) ? (unsigned)(~a + 1) : (unsigned)a;
    unsigned ub = (b < 0) ? (unsigned)(~b + 1) : (unsigned)b;
    unsigned ur = 0;

    // Shift‑and‑add multiply:
    while (ub)
    {
        if (ub & 1)
            ur += ua;
        ua <<= 1;
        ub >>= 1;
    }

    // Apply final sign (two’s‑complement if needed):
    if ((a < 0) ^ (b < 0))
        ur = ~ur + 1;

    return (int)ur;
}