# GPU Programming Lab Guidelines & Workflows

This workspace is for CUDA GPU Programming coursework and laboratory assignments (KMUTT CPE).
Follow these guidelines, tools, and execution backends when assisting with code and experiments.

---

## 1. Environment & Tools (Nix devShell)

The workspace is configured with Nix Flakes (`nix develop`). Key tools:
- **LSP / Toolchain**: `clangd` (via `clang-tools`), `bash-language-server`, `uv`, `python3`.
- **Google Colab CLI**: `google-colab-cli` managed via `uv tool` and patched automatically in `flake.nix`.
- **Slurm SSH/SCP**: Pre-configured shorthands for the KMUTT CPE Slurm portal.

---

## 2. Google Colab GPU Workflow (Interactive & Testing)

Target hardware: **NVIDIA Tesla T4 (Compute Capability `sm_75`)**.

### Standard Manual Workflow:
1. **Start / Ensure Session**:
   ```bash
   colab-start               # Starts named session 'cuda-dev' with --gpu T4
   colab-status              # Checks active sessions (colab sessions)
   ```
2. **Push File to Colab**:
   ```bash
   colab-push <subfolder>/<file.cu> [dest]   # Defaults destination to /content/<filename>
   # Examples:
   #   colab-push gpu_memory/matmult.cu
   #   colab-push matrix/matmul.cu
   #   colab-push stream/baseline.cu
   ```
3. **Open Interactive Terminal**:
   ```bash
   colab-console             # Opens bash / tmux shell on remote VM in /content
   ```
4. **Compile & Run inside Colab VM**:
   ```bash
   nvcc <file>.cu -o <bin> -arch=sm_75 && ./<bin>
   # Or with arguments:
   ./<bin> [args...]
   ```
5. **Release GPU when finished**:
   ```bash
   colab-stop                # Releases session 'cuda-dev'
   ```

### Automated Submission:
```bash
colab-submit <subfolder>/<file.cu> [-a arch] [-s session] [-t timeout] [-- <args...>]
# Example: colab-submit gpu_memory/matmult.cu
# Example: colab-submit matrix/matmul.cu -- 2048
```

---

## 3. KMUTT Slurm Cluster Workflow (High-Performance & Batch)

Target hardware: **NVIDIA RTX 4090 (Ada Lovelace, Compute Capability `sm_89`)** or `gpu4090` partition.
- **SSH Access**: `slurm-ssh` (logs into `66070503408@portal.slurm.cpe.kmutt.ac.th`).
- **File Transfer**: `slurm-scp <source>... <dest>`
  ```bash
  slurm-scp <subfolder>/<file.cu> <subfolder>/   # uploads to remote ~/<subfolder>/
  slurm-scp :<subfolder>/output.log ./           # downloads from remote
  ```
- **Batch Jobs**: Submit via `.sbatch` script (using `module load cuda/12.2` and `sbatch`).

---

## 4. CUDA Code Standards & Best Practices

When writing or refactoring CUDA kernels:
1. **Error Checking**: Always wrap CUDA runtime calls with a checking macro:
   ```cpp
   #define CHECK_CUDA(call)                                                      \
       do {                                                                      \
           cudaError_t err = call;                                               \
           if (err != cudaSuccess) {                                             \
               fprintf(stderr, "CUDA error at %s:%d: %s\n", __FILE__, __LINE__,  \
                       cudaGetErrorString(err));                                 \
               exit(EXIT_FAILURE);                                               \
           }                                                                     \
       } while (0)
   ```
2. **Memory Allocation**:
   - For synchronous baseline code: `malloc` / `cudaMalloc` / `cudaFree`.
   - For asynchronous streaming / concurrent transfers: **pinned memory** (`cudaMallocHost` / `cudaFreeHost`) is mandatory. Pageable memory cannot overlap with kernel execution.
3. **Benchmarking**:
   - Use `cudaEvent_t` (`cudaEventCreate`, `cudaEventRecord`, `cudaEventElapsedTime`).
   - Include a warm-up kernel launch before recording timings.
   - Report elapsed time in milliseconds (`ms`) and throughput in `GFLOPS` or effective bandwidth in `GB/s`.
4. **Verification**:
   - Always verify GPU results against a CPU golden reference or tolerance check (`fabs(gpu - cpu) < tol`).
