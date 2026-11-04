# Week 10 Lab Report: Profiling and Debugging

**Name:** Khem Ingkapat | **ID:** 66070503408 | **GPU:** NVIDIA Tesla T4 (sm_75) | **CUDA:** 13.0 / Driver 580.82.07 | **Env:** Google Colab

---

## Exercise 1 — Compute Sanitizer: Finding Bugs in a Broken Kernel

### Q1: Bug Identification and Fixes Table

| Bug | Description | Sanitizer Tool | Source Line (`-lineinfo`) | How Fixed in `fixed.cu` |
| :--- | :--- | :--- | :--- | :--- |
| **Bug 1** | out of bound with no guard of `gid < N`| `memcheck` | `buggy.cu:22` | add boundary check `if (gid < N) { scratch[tid] = in[gid] * 2.0f; } else { scratch[tid] = 0.0f; }` and an unconditional `__syncthreads()` afterwards. |
| **Bug 2** | `__syncthreads` inside conditional - divergence | CUDA specs, normally we wouldn't put `__syncthreads` inside condition | `buggy.cu:25` | move `__syncthreads()` outside the conditional branch so all 256 threads in the block execute. |
| **Bug 3** | shared mem race condition between write (`scratch[tid] + 1.0f`) and neighbor read (`scratch[(tid + 1) % 256]`) | `racecheck` | `buggy.cu:30` (read) vs `buggy.cu:22, 26, 29` (writes) | add `__syncthreads()`  after `scratch[tid] = scratch[tid] + 1.0f;` before any thread reads `scratch[(tid + 1) % 256]`. |
| **Bug 4** | out of bound global memory write (`out[gid] = v`) and extra atomic increments for `gid >= N` | `memcheck` | `buggy.cu:33` | guard write and atomic operation with `if (gid < N) { atomicAdd(counter, 1); out[gid] = v; }`. |

---

### Q2: Race Hazard and Non-Determinism

#### 5 Repeated Executions of `./buggy`:
- **Run 1:** `out[0] = 266.000000, counter = 1024`
- **Run 2:** `out[0] = 266.000000, counter = 1024`
- **Run 3:** `out[0] = 266.000000, counter = 1024`
- **Run 4:** `out[0] = 266.000000, counter = 1024`
- **Run 5:** `out[0] = 266.000000, counter = 1024`

#### Explanation of Non-Determinism:
even though the code is non deterministic. there are many factor that could cause it to work like deterministic version. such as lock step execution, optimization flag so that's why it seems like it is deterministic code even though it is not.

the non deterministic of this code comes from the race condition that doesn't have any barrier of read and write so the result is just up to the scheduler

---

### Q3: Compute Sanitizer Slowdown (Development vs. Production)
basically it comes down to that we "better safe than sorry". in production we need an absolute affirmation that our code or piece of software goes correctly. and in dev we might run it a couple times. in production we will run it indefinitely so that's why a slight delay could grow exponentially if we don't guard that.

we rather have slower start but firm result rather than start fast and fail fast too.

---

## Exercise 2 — Nsight Systems: Finding the Hotspot

### Q4: Kernel Time Breakdown and Hotspot Identification

From the `nsys` summary table (`cuda_gpu_kern_sum`):

| Kernel Name | Total Time (ns) | Time (%) | Instances | Avg Time (ns) | Min (ns) | Max (ns) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `slow_kernel(float*, int)` | 362,254,063 | **89.5%** | 10 | 36,225,406.3 | 21,260,411 | 52,097,962 |
| `medium_kernel(float*, int)` | 36,492,402 | **9.0%** | 10 | 3,649,240.2 | 2,327,541 | 5,532,710 |
| `fast_kernel(float*, int)` | 5,881,189 | **1.5%** | 10 | 588,118.9 | 542,685 | 632,477 |

**Hotspot Kernel:** `slow_kernel` (accounts for **89.5%** of the total kernel execution time).

---

### Q5: Optimization Choice & Amdahl's Law Reasoning

by instinct, we optimize the `slow_kernel` because the speed up factor is much larger than we optimize the `fast_kernel`. so that's why it should be better to work on that slow kernel. the margin is drastic

---

### Q6: Tool Selection (`nsys` vs `ncu`)

`nsys` is a **system-wide** profiler; `ncu` is a **kernel-level** profiler. For each of the following scenarios, identify which tool (`nsys` or `ncu`) you would use and briefly state why:

* **(a) "Is my program's wall time dominated by GPU or CPU?"**
  - Tool: `nsys`
  - Reason: because we need system wide(GPU/CPU) to see all the running time

* **(b) "Why is my kernel achieving only 30% of peak bandwidth?"**
  - Tool: `ncu`
  - Reason: see specific kernel performance

* **(c) "Are my two streams actually running concurrently?"**
  - Tool: `nsys`
  - Reason: to work with timeline to see concurrent, not why it is slow

* **(d) "Which line in my kernel causes the most warp stalls?"**
  - Tool: `ncu`
  - Reason: even though we would want to check multiple kernel, but `nsys` only support and focus on timeline so the lower level like this might need `ncu`

* **(e) "Is my memcpy overlapping with kernel execution?"**
  - Tool: `nsys`
  - Reason: again, system wide api call

---

## Exercise 3 — Nsight Compute: Kernel Analysis on Your Week 9 Kernel

### Metric Summary Table

From `ncu` output (`--set full`):

| Section | Metric Name | Metric Value / Unit |
| :--- | :--- | :--- |
| **Speed of Light (SOL)** | GPU SM Throughput (`SM [%]`) | **32.88%** |
| **Speed of Light (SOL)** | GPU Memory Throughput (`Memory [%]`) | **62.38%** |
| **Memory Workload Analysis** | L1 / TEX Cache Hit Rate (`%`) | **0.00%** |
| **Memory Workload Analysis** | L2 Cache Hit Rate (`%`) | **50.00%** |
| **Memory Workload Analysis** | Memory Throughput / DRAM Bandwidth | **199.09 GB/s** (Max Bandwidth: 62.38%) |
| **Warp State Statistics** | Top 1 Warp Stall Reason & % | **Stall Long Scoreboard (L1TEX Dependency): 52.4%** (17.2 / 32.8 cycles) |
| **Warp State Statistics** | Top 2 Warp Stall Reason & % | **Stall Barrier / Sync Wait: ~24.8%** (`__syncthreads()` intra-block exchange) |

---

### Q7: SOL Memory % vs SM % & Bound Classification
- **SOL Memory %:** 62.38%
- **SOL SM %:** 32.88%
- **Classification:** more on memory bound, since `transpose_padded` did not do any calculation, mostly data transfer
- **Week 9 Agreement:** Does this match your Week 9 prediction? Explain why. it should match since that's how we expected and crafted the kernel

---

### Q8: Cache Hit Rates & DRAM Throughput Comparison
- **L1 Hit Rate:** 0%
- **L2 Hit Rate:** 50%
- **DRAM Throughput (ncu):** 199.09 GB/s
- **Week 9 Measured Bandwidth:** (Week 9 `transpose_padded` was ~179.17 GB/s)
- **Comparison & Agreement:** Do they agree within 10%? Explain any difference. it is right around 10%

---

### Q9: Top 2 Warp Stall Reasons
- **Stall Reason 1 & %:**
  - *Explanation:* that data is not arrive yet so warp couldn't be sent to the scheduler to execute
- **Stall Reason 2 & %:**
  - *Explanation:* `__syncthreads` which stall warp to make sure every thread in block wait for the execute to be coherent
- **Expected Behavior for Memory-Bound Kernel:** Does this match expectations? Why?

yes, memory bound = waiting for data, not compute which this shows the data stall

---

### Q10: Next Optimization Technique
*If SOL Memory % is ~80% and SM % is ~20%, what optimization technique from Week 9 (e.g. coarse-graining/ILP, 2D register tiling, vector loads float4, etc.) would you try next to push closer to 100% memory bandwidth? Justify your choice.*

**Answer:**

i think the vectorized load would help, since each thread doesn't process anything, giving it more data to work with seems like a good idea to utilize the bandwidth more and pushing it forward to limit


---

## Exercise 4 — cuda-gdb: Debugging a Logic Bug

### Q11: Why Compute Sanitizer Missed the Bug
*Why did Compute Sanitizer NOT catch this bug? (Sanitizer detects memory + sync errors, but this is a...)*

**Answer:**
sanitizer focus on what's wrong on the code level, not the logic. it is like when we normally code, when compile it shows no error even though the logic is completely wrong. it focused on violation, not what's wrong logically.


---

### Q12: `cuda-gdb` vs `printf` Debugging
*Under what circumstances would you reach for `cuda-gdb` over printf-debugging (device `printf` works in kernels)? Give one scenario where `cuda-gdb` is clearly better.*

**Answer:**
most of the time I used the `printf`, but debugger in general works better to tracing the error when there are many interconnected components where sometimes it is hard to trace where does the error comes from. and imagine we have very deep loop, every time it spit out something every iteration. that would be impossible to use printf


---

### Q13: `-G` vs `-O2` Build and Execution Comparison
*Report compilation times and runtime behavior: `time nvcc -G -g ...` vs `time nvcc -O2 -lineinfo ...`. Why is `-G` significantly slower to compile and run?*

| Build Flag | Compilation Time (`real`) | Kernel / Execution Characteristics |
| :--- | :---: | :--- |
| `nvcc -O2 -lineinfo` | **1.433s** (user 1.141s, sys 0.257s) | **Fast GPU Runtime (100% speed)**. Full compiler optimizations enabled, variables held in fast registers, instructions scheduled for latency hiding. |
| `nvcc -G -g` | **1.213s** (user 0.955s, sys 0.245s) | **Slow GPU Runtime (10–50× slower)**. Zero GPU optimizations, variables spilled to local memory (DRAM) to support debugger inspection, no register reuse. |

**Explanation:**
1. **Compilation Time:**
`-G` ran faster since it doesn't do any optimization, so less overhead on the compile time
2. **Runtime Execution:**
theoretically, `-G` should be much slower due to no optimization being done, and also the tracing for debugging tool

---

## Exercise 5 — NVTX Annotations

### NVTX Range Statistics Summary

From `nsys` summary table (`nvtx_pushpop_sum`):

| Range Name | Total Time (ns) | Instances | Avg Time (ns) | Med Time (ns) | Min (ns) | Max (ns) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `:Setup` | 509,753,793 (~509.8 ms) | 1 | 509,753,793.0 | 509,753,793.0 | 509,753,793 | 509,753,793 |
| `:Iteration` | 523,734 (~0.52 ms) | 10 | 52,373.4 | 14,603.5 | 14,167 | 391,103 |
| `:Fast phase` | 375,700 (~0.38 ms) | 10 | 37,570.0 | 4,676.0 | 4,358 | 333,002 |
| `:Cleanup` | 251,193 (~0.25 ms) | 1 | 251,193.0 | 251,193.0 | 251,193 | 251,193 |
| `:Medium phase` | 70,383 (~0.07 ms) | 10 | 7,038.3 | 4,548.0 | 4,347 | 29,126 |
| `:Slow phase` | 67,493 (~0.07 ms) | 10 | 6,749.3 | 4,542.0 | 4,300 | 26,181 |

**Total time in "Slow phase" ranges across all 10 iterations:** **67,493 ns** (~67.5 μs CPU launch enqueue time; GPU kernel execution time: **~362.3 ms** as measured in Exercise 2).

---

### Q14: Added Value of NVTX Ranges vs Raw Kernel Names
*Compare the `nsys` output from Exercise 2 (no NVTX) to this one (with NVTX). What information do the NVTX ranges add that raw kernel names alone don't?*

**Answer:**
basically naming alone would help to detect, by just not have to figure out which name refer to which components would help a lot already. it also help figuring out the relation by name and timeline


---

### Q15: Importance of Zero-Overhead Property
*NVTX has ZERO OVERHEAD when profiling is disabled. Why is this property important for production code that will be shipped with annotations left in place?*

**Answer:**
like we discussed that we would allow delay or latency in dev only, production code must be as flawless as it could. so ability to be able to make a code easy to work with with no overhead penalty is a bliss


---

## Reflection
I didn't join this class, but the lab is straightforward enough. Even though those tools are not a tools that I familiar with but the purpose of each is quite straightforward so that's why it make this lab quite fun.
