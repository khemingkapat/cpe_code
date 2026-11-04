# Week 10: GPU Profiling and Debugging

This directory contains implementations, profiling scripts, reports, and sanitizer logs for Week 10 Lab.

## Environment Requirements
- **NVIDIA GPU:** Compute capability `sm_75` (e.g., Google Colab Tesla T4) or `sm_89` (Slurm RTX 4090).
- **Tools:** `nvcc`, `compute-sanitizer`, `nsys`, `ncu`, `cuda-gdb`.

---

## Exercise 1 — Compute Sanitizer

### Files
- [`buggy.cu`](file:///home/khemi/workspace/cpe_code/gpu_programming/profiling/buggy.cu): Broken kernel with 4 deliberate bugs (OOB read, divergent barrier, shared memory race, OOB write).
- [`fixed.cu`](file:///home/khemi/workspace/cpe_code/gpu_programming/profiling/fixed.cu): Fixed kernel passing all sanitizers with 0 errors.
- [`memcheck.txt`](file:///home/khemi/workspace/cpe_code/gpu_programming/profiling/memcheck.txt): Log from `compute-sanitizer --tool memcheck ./buggy` (flags OOB read/write).
- [`racecheck.txt`](file:///home/khemi/workspace/cpe_code/gpu_programming/profiling/racecheck.txt): Log from `compute-sanitizer --tool racecheck ./buggy` (flags shared memory hazards).
- [`initcheck.txt`](file:///home/khemi/workspace/cpe_code/gpu_programming/profiling/initcheck.txt): Log from `compute-sanitizer --tool initcheck ./buggy`.
- [`synccheck.txt`](file:///home/khemi/workspace/cpe_code/gpu_programming/profiling/synccheck.txt): Log from `compute-sanitizer --tool synccheck ./buggy`.
- [`fixed_output.txt`](file:///home/khemi/workspace/cpe_code/gpu_programming/profiling/fixed_output.txt) / [`fixed.txt`](file:///home/khemi/workspace/cpe_code/gpu_programming/profiling/fixed.txt): Output proving 0 errors across all 4 sanitizers for `./fixed`.
- [`runs5.txt`](file:///home/khemi/workspace/cpe_code/gpu_programming/profiling/runs5.txt): 5 runs of the buggy kernel recording `out[0]`.

### Build & Run Commands

#### 1. Buggy Kernel
```bash
# Compile with lineinfo for source-code correlation
nvcc -O2 -lineinfo -arch=sm_75 buggy.cu -o buggy

# Run the 4 sanitizer tools
compute-sanitizer --tool memcheck  ./buggy > memcheck.txt 2>&1
compute-sanitizer --tool racecheck ./buggy > racecheck.txt 2>&1
compute-sanitizer --tool initcheck ./buggy > initcheck.txt 2>&1
compute-sanitizer --tool synccheck ./buggy > synccheck.txt 2>&1

# Run 5 times for Q2
for i in {1..5}; do ./buggy; done
```

#### 2. Fixed Kernel
```bash
# Compile
nvcc -O2 -lineinfo -arch=sm_75 fixed.cu -o fixed

# Verify zero errors across all tools
compute-sanitizer --tool memcheck  ./fixed
compute-sanitizer --tool racecheck ./fixed
compute-sanitizer --tool initcheck ./fixed
compute-sanitizer --tool synccheck ./fixed
```
