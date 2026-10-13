# CPE 393 GPU Programming – Midterm Concept Summary

**Author / Student**: Khem Ingkapat (ID: 66070503408)  
**Exam Target**: October 23, 2026 | 9:00 AM – 12:00 PM | Room CPE 1115  
**Hardware Baselines**:
- Google Colab: **NVIDIA Tesla T4** (Turing sm_75, 2560 CUDA cores, 40 SMs, Peak BW: ~320 GB/s)
- KMUTT Slurm: **NVIDIA RTX 4090** (Ada Lovelace sm_89, 16384 CUDA cores, 128 SMs, Peak BW: ~1008 GB/s)

---

## 1. CUDA Execution Model & Hardware Structure (`cuda_structure/`)

### Key Concepts
- **Thread Hierarchy**: Threads $\rightarrow$ Warps (32 threads) $\rightarrow$ Thread Blocks $\rightarrow$ Grid.
- **SIMT (Single Instruction, Multiple Threads)**: Hardware executes instructions at warp granularity (32 threads lock-stepped).
- **Warp Divergence**:
  - Occurs when threads within the **same warp** follow different conditional branches (`if-else`).
  - The hardware serializes the branches, executing each path with inactive threads masked off.
  - **Intra-warp divergence** (e.g., `tid % 2 == 0` or `input[i] < 16` with random input): severe performance drop.
  - **Warp-aligned branching** (e.g., `(tid / 32) % 2 == 0`): No divergence because all 32 threads in any given warp follow the exact same path.

### Core Indexing Formulas
- **1D Grid**:
  ```cuda
  int gid = blockIdx.x * blockDim.x + threadIdx.x;
  ```
- **Grid sizing (Round up)**:
  ```cuda
  int grid_size = (N + block_size - 1) / block_size;
  ```

### Device Properties & Theoretical Calculations
- **Theoretical Peak Memory Bandwidth (GB/s)**:
  $$\text{BW}_{\text{peak}} = \frac{2 \times \text{Memory Clock Rate (Hz)} \times \text{Memory Bus Width (bits)}}{8 \times 10^9}$$
  *Example (T4)*: Memory Clock = 5001 MHz, Bus Width = 256 bits $\implies (2 \times 5001 \times 10^6 \times 256) / (8 \times 10^9) \approx 320.0 \text{ GB/s}$.
- **Effective Memory Bandwidth (GB/s)**:
  $$\text{BW}_{\text{eff}} = \frac{\text{Bytes Read} + \text{Bytes Written}}{\text{Time (seconds)} \times 10^9}$$

---

## 2. 2D Coordinates, Stencils & Coalescing (`matrix/`)

### Key Concepts
- **Row-Major Memory Order**: Elements along the same row are consecutive in DRAM (`A[row * width + col]`).
- **2D Thread Indexing**:
  ```cuda
  int col = blockIdx.x * blockDim.x + threadIdx.x; // Fast changing (x)
  int row = blockIdx.y * blockDim.y + threadIdx.y; // Slow changing (y)
  ```
- **Boundary Checking**: Essential whenever matrix dimension $N$ is not an exact multiple of `blockDim`:
  ```cuda
  if (row < height && col < width) { ... }
  ```
- **Block Shape vs Memory Coalescing**:
  - Threads in a warp have consecutive `threadIdx.x`.
  - For `block(32, 8)`: A warp of 32 threads accesses 32 consecutive columns in the same row $\rightarrow$ **Coalesced 128-byte global memory transaction**.
  - For `block(8, 32)`: A warp spans multiple rows $\rightarrow$ **Strided memory transactions**, requiring multiple 32-byte cache line loads.

---

## 3. Shared Memory & Tiling (`gpu_memory/`)

### Key Concepts
- **Memory Hierarchy**:
  - Registers (Fastest, private to thread)
  - Shared Memory (`__shared__`, on-chip, shared within a block, ~tens of cycles)
  - L1 / L2 Cache
  - Global Memory (DRAM, high latency ~200-400 cycles, bandwidth bottleneck)
- **Tiled Matrix Multiplication**:
  - Eliminates redundant global memory loads by caching tiles in shared memory.
  - **Arithmetic Intensity** jumps from $\approx 0.25 \text{ FLOP/byte}$ (naive) to $\approx \frac{\text{TILE\_WIDTH}}{4} \text{ FLOP/byte}$.
  - Requires **two `__syncthreads()`**:
    1. First barrier: Ensures all threads have finished loading their element into shared memory before any thread begins computing.
    2. Second barrier: Ensures all threads have finished computing with the current tile before any thread overwrites the tile in the next iteration.

### Boundary-Guarded Tiled MatMul Implementation
```cuda
template <int TILE_WIDTH>
__global__ void matmul_tiled_bounded(const float* A, const float* B, float* C, int N) {
    __shared__ float s_A[TILE_WIDTH][TILE_WIDTH];
    __shared__ float s_B[TILE_WIDTH][TILE_WIDTH];

    int row = blockIdx.y * TILE_WIDTH + threadIdx.y;
    int col = blockIdx.x * TILE_WIDTH + threadIdx.x;
    float sum = 0.0f;

    int numTiles = (N + TILE_WIDTH - 1) / TILE_WIDTH;

    for (int m = 0; m < numTiles; ++m) {
        int a_col = m * TILE_WIDTH + threadIdx.x;
        int b_row = m * TILE_WIDTH + threadIdx.y;

        // Zero-padding guard for out-of-bounds reads
        s_A[threadIdx.y][threadIdx.x] = (row < N && a_col < N) ? A[row * N + a_col] : 0.0f;
        s_B[threadIdx.y][threadIdx.x] = (b_row < N && col < N) ? B[b_row * N + col] : 0.0f;

        __syncthreads();

        #pragma unroll
        for (int k = 0; k < TILE_WIDTH; ++k) {
            sum += s_A[threadIdx.y][k] * s_B[k][threadIdx.x];
        }

        __syncthreads();
    }

    if (row < N && col < N) {
        C[row * N + col] = sum;
    }
}
```

---

## 4. Parallel Reduction (`reduction/`)

### Key Concepts
- **Tree Reduction Pattern**: Reduces $O(N)$ sequential operations to $O(\log N)$ parallel steps.
- **Interleaved vs. Sequential Addressing**:
  - *Interleaved* (`if (tid % (2 * s) == 0)`): Causes heavy warp divergence because active threads are spread out across warps.
  - *Sequential* (`if (tid < s) sdata[tid] += sdata[tid + s]`): Divergence-free until the active thread count drops below 32 (a single warp).
- **Thread Coarsening**: Each thread sums `COARSE` elements directly from global memory before the tree reduction starts. This saturates memory bandwidth and reduces grid launch overhead.
- **Floating Point Stability**: Adding single-precision floats one by one ($1.0f$) loses precision past $2^{24}$ (16,777,216) due to 23-bit mantissa exhaustion. Pairwise tree reduction preserves precision.

### Sequential Tree Reduction Kernel Core
```cuda
__global__ void reduce_block(const float *in, float *out, unsigned n) {
    __shared__ float sdata[BLOCK_SIZE];
    unsigned tid = threadIdx.x;
    unsigned base = blockIdx.x * (BLOCK_SIZE * COARSE) + tid;

    // 1. Thread coarsening
    float sum = 0.0f;
    for (int c = 0; c < COARSE; ++c) {
        unsigned idx = base + c * BLOCK_SIZE;
        if (idx < n) sum += in[idx];
    }
    sdata[tid] = sum;
    __syncthreads();

    // 2. Sequential addressing tree
    for (unsigned s = BLOCK_SIZE / 2; s > 0; s >>= 1) {
        if (tid < s) {
            sdata[tid] += sdata[tid + s];
        }
        __syncthreads();
    }

    // 3. Write partial sum to output
    if (tid == 0) out[blockIdx.x] = sdata[0];
}
```

---

## 5. CUDA Streams, Concurrency & Overlapping (`stream/`)

### Key Concepts
- **Pinned (Page-Locked) Memory (`cudaMallocHost`)**:
  - OS cannot page memory to disk; physical address is fixed.
  - Enables GPU DMA (Direct Memory Access) engine to copy memory without CPU intervention.
  - Achieves full PCIe bandwidth (~11-12 GB/s on PCIe Gen3 x16, vs ~4-5 GB/s with pageable memory).
  - **Required** for true asynchronous memory copy (`cudaMemcpyAsync`).
- **Multi-Stream Pipelining**:
  - Modern GPUs have separate Copy Engines (H2D, D2H) and Compute Engines.
  - Overlaps `HostToDevice` copy of chunk $i+1$, `Kernel` execution of chunk $i$, and `DeviceToHost` copy of chunk $i-1$.
  - Theoretical speedup approaches $\approx 1.4\text{x} - 1.5\text{x}$ when transfer time equals compute time.
- **Cross-Stream Event Synchronization**:
  - `cudaEventRecord(event, stream)`: Records an event in a stream queue.
  - `cudaStreamWaitEvent(target_stream, event, 0)`: Enqueues a wait in the GPU scheduler. **Non-blocking on host CPU!**
- **CUDA Graphs**:
  - Eliminates CPU driver launch overhead (~5 $\mu$s per kernel launch) by capturing the execution graph once and re-instantiating it with a single launch call.

### Multi-Stream Pipeline Code Pattern
```cuda
for (int i = 0; i < N_CHUNKS; ++i) {
    int s = i % N_STREAMS;
    int offset = i * CHUNK_SIZE;

    cudaMemcpyAsync(&d_in[offset], &h_in[offset], bytes_chunk,
                    cudaMemcpyHostToDevice, streams[s]);

    kernel<<<grid, block, 0, streams[s]>>>(&d_in[offset], &d_out[offset], CHUNK_SIZE);

    cudaMemcpyAsync(&h_out[offset], &d_out[offset], bytes_chunk,
                    cudaMemcpyDeviceToHost, streams[s]);
}

for (int s = 0; s < N_STREAMS; ++s) {
    cudaStreamSynchronize(streams[s]);
}
```

---

## 6. Performance Optimizations Reference (`performance/`)

- **Bank Conflicts in Shared Memory**:
  - Shared memory is divided into **32 independent banks** (4 bytes per bank).
  - Consecutive 32-bit words map to consecutive banks: $\text{Bank} = (\text{Word Offset}) \pmod{32}$.
  - A conflict occurs when multiple threads in a warp access different words within the *same* bank.
  - **Transpose fix**: Pad shared memory 2D arrays: `__shared__ float tile[32][33];` (avoids 32-way conflict).
- **Warp Shuffle Intrinsics (`__shfl_down_sync`)**:
  - Directly exchanges register values between threads in the same warp without shared memory:
  ```cuda
  __device__ inline float warpReduceSum(float val) {
      for (int offset = 16; offset > 0; offset /= 2) {
          val += __shfl_down_sync(0xffffffff, val, offset);
      }
      return val;
  }
  ```
