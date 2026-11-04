# Week 10: GPU Profiling and Debugging

**Course:** GPU Computing
**Student:** Khem Ingkapat (ID: 66070503408)
**Environment:** Google Colab GPU (Tesla T4, Compute Capability `sm_75`, CUDA 13.0, Driver 580.82.07)

This directory contains all source code implementations, profiler reports, sanitizer logs, and the completed analysis report for Week 10 Lab.

---

## Directory Structure & Deliverables

| Deliverable File | Exercise | Description |
| :--- | :---: | :--- |
| [`REPORT.md`](REPORT.md) | **All** | Complete lab report containing answers for **Q1 through Q15** and metric summaries |
| [`buggy.cu`](buggy.cu) | **Ex 1** | Buggy kernel implementing all 4 deliberate bugs (OOB read/write, divergent barrier, race) |
| [`fixed.cu`](fixed.cu) | **Ex 1** | Repaired kernel with all 4 bugs eliminated |
| [`memcheck.txt`](memcheck.txt) | **Ex 1** | `compute-sanitizer --tool memcheck ./buggy` output (detects 26 out-of-bounds errors) |
| [`racecheck.txt`](racecheck.txt) | **Ex 1** | `compute-sanitizer --tool racecheck ./buggy` output (detects shared memory data race) |
| [`initcheck.txt`](initcheck.txt) | **Ex 1** | `compute-sanitizer --tool initcheck ./buggy` output (0 uninitialized read errors) |
| [`synccheck.txt`](synccheck.txt) | **Ex 1** | `compute-sanitizer --tool synccheck ./buggy` output (barrier synchronization check) |
| [`fixed_output.txt`](fixed_output.txt) | **Ex 1** | Proof of 0 errors / 0 hazards across all 4 sanitizers for `./fixed` |
| [`runs5.txt`](runs5.txt) | **Ex 1** | Output of 5 consecutive runs of `./buggy` (counter = 1024) |
| [`pipeline.cu`](pipeline.cu) | **Ex 2** | 3-stage pipeline benchmark (`fast_kernel`, `slow_kernel`, `medium_kernel`) |
| [`pipeline_report.nsys-rep`](pipeline_report.nsys-rep) | **Ex 2** | Nsight Systems full profile report file |
| [`pipeline_stats.txt`](pipeline_stats.txt) | **Ex 2** | Kernel execution summary table (`cuda_gpu_kern_sum`) identifying `slow_kernel` hotspot |
| [`transpose.cu`](transpose.cu) | **Ex 3** | Week 9 matrix transpose implementation (`coalesced + padded`) |
| [`transpose_report.ncu-rep`](transpose_report.ncu-rep) | **Ex 3** | Nsight Compute full profile report file (`--set full`) |
| [`ncu_output.txt`](ncu_output.txt) | **Ex 3** | Detailed CLI text output (`--page details`) with SOL, memory, and warp stall metrics |
| [`logic_bug.cu`](logic_bug.cu) | **Ex 4** | Kernel containing the off-by-one logic bug (`k < gid`) |
| [`logic_fixed.cu`](logic_fixed.cu) | **Ex 4** | Corrected kernel (`k <= gid`) passing verification (`out[gid] = gid + 1`) |
| [`script.gdb`](script.gdb) | **Ex 4** | GDB command file used to inspect thread 0 and thread 5 |
| [`cudagdb_session.txt`](cudagdb_session.txt) | **Ex 4** | Transcript of the `cuda-gdb` debugging session |
| [`pipeline_nvtx.cu`](pipeline_nvtx.cu) | **Ex 5** | 3-stage pipeline annotated with NVTX v3 range markers (`Setup`, `Iteration`, phases, `Cleanup`) |
| [`pipeline_nvtx_report.nsys-rep`](pipeline_nvtx_report.nsys-rep) | **Ex 5** | Nsight Systems report file capturing CUDA + NVTX events |
| [`pipeline_nvtx_stats.txt`](pipeline_nvtx_stats.txt) | **Ex 5** | NVTX Push/Pop range summary table (`nvtx_pushpop_sum`) |

---

## Build and Execution Guide by Exercise

### Exercise 1 — Compute Sanitizer: Broken vs Fixed Kernel

```bash
# 1. Compile buggy kernel with lineinfo
nvcc -O2 -lineinfo -arch=sm_75 buggy.cu -o buggy

# 2. Run all 4 sanitizer tools
compute-sanitizer --tool memcheck  ./buggy > memcheck.txt 2>&1
compute-sanitizer --tool racecheck ./buggy > racecheck.txt 2>&1
compute-sanitizer --tool initcheck ./buggy > initcheck.txt 2>&1
compute-sanitizer --tool synccheck ./buggy > synccheck.txt 2>&1

# 3. Run 5 consecutive iterations for Q2
for i in {1..5}; do ./buggy; done > runs5.txt

# 4. Compile and verify fixed kernel
nvcc -O2 -lineinfo -arch=sm_75 fixed.cu -o fixed
{
  compute-sanitizer --tool memcheck  ./fixed
  compute-sanitizer --tool racecheck ./fixed
  compute-sanitizer --tool initcheck ./fixed
  compute-sanitizer --tool synccheck ./fixed
} > fixed_output.txt 2>&1
```

---

### Exercise 2 — Nsight Systems: Application-Level Hotspot Analysis

```bash
# 1. Compile pipeline workload
nvcc -O2 -lineinfo -arch=sm_75 pipeline.cu -o pipeline

# 2. Profile with Nsight Systems (CUDA trace + stats)
nsys profile --stats=true -t cuda -o pipeline_report ./pipeline

# 3. Export kernel execution summary table
nsys stats --force-export=true --report cuda_gpu_kern_sum pipeline_report.nsys-rep > pipeline_stats.txt
```

---

### Exercise 3 — Nsight Compute: Kernel Roofline & Microarchitecture

```bash
# 1. Compile padded transpose kernel with lineinfo
nvcc -O2 -lineinfo -arch=sm_75 transpose.cu -o transpose

# 2. Profile full hardware counter set on padded transpose
ncu --set full -k transpose_padded -c 1 -o transpose_report ./transpose

# 3. Export full text report with section details
ncu --set full -k transpose_padded -c 1 --page details ./transpose > ncu_output.txt
```

---

### Exercise 4 — CUDA-GDB: Debugging a Logic Bug

```bash
# 1. Compile with full debug symbols (no optimizations)
nvcc -G -g -arch=sm_75 logic_bug.cu -o logic_bug

# 2. Run scripted cuda-gdb session and record transcript
cuda-gdb -batch -x script.gdb ./logic_bug > cudagdb_session.txt 2>&1

# 3. Benchmark compilation times (-O2 vs -G) for Q13
time nvcc -O2 -lineinfo -arch=sm_75 logic_bug.cu -o logic_opt
time nvcc -G -g -arch=sm_75 logic_bug.cu -o logic_debug

# 4. Compile and verify fixed kernel
nvcc -O2 -lineinfo -arch=sm_75 logic_fixed.cu -o logic_fixed
./logic_fixed
```

---

### Exercise 5 — NVTX: Source Code Annotations

```bash
# 1. Compile annotated pipeline (header-only, no extra linking needed on Linux)
nvcc -O2 -lineinfo -arch=sm_75 pipeline_nvtx.cu -o pipeline_nvtx

# 2. Profile with Nsight Systems tracing both CUDA and NVTX
nsys profile --stats=true -t cuda,nvtx -o pipeline_nvtx_report ./pipeline_nvtx

# 3. Export NVTX push/pop range statistics table
nsys stats --force-export=true --report nvtx_pushpop_sum pipeline_nvtx_report.nsys-rep > pipeline_nvtx_stats.txt
```
