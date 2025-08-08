# benchmark-dhrystone
"DHRYSTONE" Benchmark Program by  Reinhold P. Weicker.

Ported from sifive's [benchmark-dhrystone](https://github.com/sifive/benchmark-dhrystone)

## Results

**Iterations:** 500  
**Instruction Count:** 177,143  
**Control Transfers:** 35,577  

| **BTB Size** | **Total Cycles** (`dec`) | **Wrong Branches** | **CPI** | **Misprediction Rate** |
| ------------ | ------------------------ | ------------------ | ------- | ---------------------  |
| Off          | 230,531                  | 20,746             | 1.30    | 58.3%                  |
| 16           | 223,233                  | 18,729             | 1.26    | 52.6%                  |
| 32           | 216,683                  | 13,758             | 1.22    | 38.7%                  |
| 64           | 210,899                  | 12,082             | 1.19    | 34.0%                  |cd 
| 128          | 206,703                  | 9,024              | 1.17    | 25.4%                  |
| 256          | 206,703                  | 9,024              | 1.17    | 25.4%                  |

**Iterations:** 500  
| **BTB Type**                 | **Total Cycles** | **Wrong Branches** | **CPI** | **Misprediction Rate** |
|------------------------------|------------------|--------------------|---------|------------------------|
| Simple 128 BTB               | 413,085          | 18,024             | 1.164   | 25.75%                 |
| Gshare 128 BTB 1024 PHT      | 451,639          | 38,005             | 1.274   | 54.29%                 |
