# Week 9 Lab Report
Student name: Khem Ingkapat
Student ID: 66070503408
Date: 7/9/2026
GPU used: Tesla T4, 7.5
GPU peak bandwidth: 320 GB/s
Environment: Colab
CUDA toolkit version: 12.8
Time spent: 6 hours

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
========================================================================================
variant                  time (ms)    bandwidth (GB/s)   speedup vs naive   % of peak
----------------------------------------------------------------------------------------
naive                    9.017        59.54              1.00               18.61       %
coalesced                6.583        81.55              1.37               25.48       %
coalesced + padded       2.996        179.17             3.01               55.99       %
========================================================================================
Padded vs Coalesced Speedup: 2.20x (54.5% improvement)
========================================================================================

Q7: about 54.5 % speed up with the coalesced. but also 67.1% from the naive one. it is the shared memory blank conflict. not the whole reading and writing things. so this is just one part that we now optimized it to works on its best and contribute this much amount
Q8: Yes, that there is a cost of padding. which is at 3% increase in memory usage per tile. and then if we take the the 100KB limit now we could only have 24 instead of 25 block per sm. but in 3 percent more memory usage per tile but at 50% in time improvement. that's the fact that we cant discard.

also there are other limits, such as thread per sm, registers, etc. Maybe in some case we might reached that limit before the memory limit so that's why it would not be that big of a deal
Q9: maybe padding here is fits better. from this [link](https://apxml.com/courses/compiler-optimizations-machine-learning/chapter-5-hardware-aware-code-generation/shared-memory-banking-conflicts). it said that swizzling strenghts' are on the tight memory kernel and also when we need vectorize load. so our kernel is not really that type so padding - the simpler fix just works here.

## Exercise 4 — Warp Shuffle Reduction
========================================================================================
variant              time (ms)       bandwidth (GB/s)   speedup vs shared  % of peak
----------------------------------------------------------------------------------------
shared mem           9.924           54.10              1.00               16.91       %
warp shuffle         5.303           101.24             1.87               31.64       %
========================================================================================
Q10: so basically it helps with the speed up of the memory bound since we are not waiting for thread to finished loading with `__synchtreads` anymore, we can go for each warp, and the shuffling take so little time, much lower than the shared memory so that's why it helps.
Q11: from the calculation, in implementation a we need 8 reduction iteration. which each for 25 cycles so 200 cycles. but for 32 thread in warps. we only 5 for each warps. and then another 5 from reduction across warps so 5+5 cycles and one read write adding the total cycle counts to be around 50. so we could save like 150 cycles
Q12: I predicted that the B wil be faster, but not large margin. since now the load time and compute time would be quite similar. the saving margin wouldn't be so large

## Bonus (if attempted)
[progressive plot]
BQ1: (highest % of peak)
BQ2: (technique not applied)

## Reflection (optional)
quite fun actually. the results goes along what we have learn.
