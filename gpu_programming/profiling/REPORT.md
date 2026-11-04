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

