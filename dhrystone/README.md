# benchmark-dhrystone
"DHRYSTONE" Benchmark Program by  Reinhold P. Weicker.

Ported from sifive's [benchmark-dhrystone](https://github.com/sifive/benchmark-dhrystone)

## Results

**Iterations:** 500

| BTB Size | Total Cycles     | Wrong Branches   | Control Transfers |
|----------|------------------|------------------|-------------------|
| Off      | `0x00038281`     | `0x0000520A`     | `0x0000520A`      |
| 16       | `0x000353B5`     | `0x00003AA4`     | `0x0000520A`      |
| 32       | `0x00034037`     | `0x000030E5`     | `0x0000520A`      |
| 64       | `0x00033485`     | `0x00002B0C`     | `0x0000520A`      |
| 128      | `0x000324ED`     | `0x00002340`     | `0x0000520A`      |
| 256      | `0x000324ED`     | `0x00002340`     | `0x0000520A`      |