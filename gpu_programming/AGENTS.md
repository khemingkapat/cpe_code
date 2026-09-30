# GPU Programming Lab Agent Instructions

You are assisting with CUDA GPU programming assignments, benchmarks, and laboratory experiments.

## Project Structure
- `matrix/`: Matrix multiplication implementations (naive, tiled shared memory, 2D register tiled) and Slurm scripts.
- `gpu_memory/`: Memory hierarchy experiments (global, shared, registers, cache).
- `stream/`: CUDA Streams, chunking, concurrency, pinned host memory vs pageable memory, overlapping compute and data transfer.
- `flake.nix`: Nix environment configuring all LSP, build tools, Slurm SSH/SCP, and Google Colab CLI helpers.

## Core Workflows
1. **Google Colab GPU (`T4`, `-arch=sm_75`)**:
   - `colab-start`: Spawns or connects to `cuda-dev` GPU runtime.
   - `colab-push <file.cu>`: Uploads local file to `/content/<filename>`.
   - `colab-console`: Opens interactive shell on Colab VM to run `nvcc <file>.cu -o <bin> -arch=sm_75 && ./<bin>`.
   - `colab-submit <file.cu> [-- <args...>]`: One-shot build and run.
   - `colab-stop`: Frees GPU compute units when finished.
2. **KMUTT Slurm Cluster (`RTX 4090`, `-arch=sm_89`)**:
   - `slurm-ssh`: Login to the portal.
   - `slurm-scp <src>... <dest>`: Transfer files.
   - Use `.sbatch` scripts for batch job submission.

## CUDA Implementation Conventions
- Use `CHECK_CUDA(call)` error-checking macro for all CUDA API calls and `cudaGetLastError()`.
- Use `cudaEvent_t` for timing with warmup iterations.
- Verify accuracy against CPU or baseline.
- For async streams (`cudaMemcpyAsync`), always use pinned host memory (`cudaMallocHost` / `cudaFreeHost`).
