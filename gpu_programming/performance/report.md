# Week 9 Lab Report
Student name: Khem Ingkapat
Student ID: 66070503408
Date: 7/9/2026
GPU used: Tesla T4, 7.5
GPU peak bandwidth: 320 GB/s
Environment: Colab
CUDA toolkit version: 12.8
Time spent: ___ hours

## Exercise 1 — Naive Transpose Roofline Positioning
```bash
============================================================
Exercise 1: Roofline Positioning of Naive Transpose
============================================================
GPU Device: Tesla T4 (Compute Capability 7.5)
Theoretical Peak Memory Bandwidth (T4 spec): 320.0 GB/s
Matrix Dimension: 8192 x 8192 (67108864 elements)
Memory per matrix: 256.00 MB (Total for in + out: 512.00 MB)
============================================================

Allocating host memory...
Initializing input matrix...
Allocating device memory...
Launch configuration: Block (32, 32), Grid (256, 256)
Running warm-up kernel launch...
Benchmarking naive transpose over 5 trials...
  Trial 1: 8.857 ms
  Trial 2: 8.869 ms
  Trial 3: 8.868 ms
  Trial 4: 8.866 ms
  Trial 5: 8.877 ms

--- Performance Results ---
Average Kernel Time: 8.867 ms
Effective Bandwidth: 60.54 GB/s
Percentage of Peak Bandwidth: 18.92 %

--- Correctness Verification ---
Computing CPU golden reference transpose...
Verification PASSED: GPU output exactly matches CPU output (memcmp returned 0).
Sample spot-check (matrix corners):
  in[0, 0] = 0.000000  -> out[0, 0] = 0.000000
  in[0, 1] = 0.001000  -> out[1, 0] = 0.001000
  in[1, 0] = 0.192000  -> out[0, 1] = 0.192000
  in[N-1, N-1] = 0.863000 -> out[N-1, N-1] = 0.863000
```

Q1: Tesla T4, 8192, ~8.86ms, 60.54 GB/s

Q2: Peaked at 18.92%, since the write out is not coalescing on our row-major storing. it could go up to 32 turn per warp - means each thread in the warp read on different chunk of memory

Q3: from the concept, the read is coalescing. means that we need to read 128 bytes (4 bytes of float * 32 from warps) from read, that we read. so we read coalescingly from each burst in the HBM so that's straight 128 useful bytes out of 128 bytes read. but for right. we need only 4 bytes from each sector that sits far apart from each other(8192 * 4 bytes per row), so we ending reading 32 sectors -> 1024 bytes but only 128 is useful

so that theoretical it is 128 bytes read + 128 bytes write, but actually it is 128 bytes read + 1024 bytes right. so that's end up to be 256 / 1152 = 0.22 or 22% - which debatable that it is close to our experiment at 18.92% - it might vary through a lot of factors.

## Exercise 2 — Coalesced Transpose
======================================================================
variant              time (ms)       bandwidth (GB/s)   speedup vs naive % of peak
----------------------------------------------------------------------
naive                8.866           60.55              1.00            18.92       %
coalesced            6.217           86.36              1.43            26.99       %
======================================================================
Q4: bandwidth at 86.36 GB/s, which bumps up from naive one from 18.92% -> 26.99%

Q5: we separated the process into 2 phase, read and write. with read coalescingly from the global mem into the shared memory, and then coalescingly write into global output that's how we speed upt

Q6: it comes down to the write to shared memory, since we said we could read from global COALESCINGLY since the memory is consecutive but the write onto the same bank in shared memory is sequential.

## Exercise 3 — Bank Conflict Elimination
[updated timing table with all three variants]
Q7: (padding speedup)
Q8: (occupancy cost of padding)
Q9: (padding vs swizzling)

## Exercise 4 — Warp Shuffle Reduction
[timing table]
Q10: (why shuffle helps in memory-bound workload)
Q11: (cycles saved per block)
Q12: (prediction for N=1024)

## Bonus (if attempted)
[progressive plot]
BQ1: (highest % of peak)
BQ2: (technique not applied)

## Reflection (optional)
What was most surprising? What would you investigate next?
