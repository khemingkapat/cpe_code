#include <cuda_runtime.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define BLOCK_SIZE 256
#define NUM_TRIALS 5
#define DEFAULT_N (128 * 1024 * 1024) // 128M elements (512 MB)

// Peak bandwidth for Tesla T4 is ~320.0 GB/s (from spec sheet / Week 4 lab)
#define T4_PEAK_BANDWIDTH_GB_S 320.0

// Implementation A: Standard shared-memory reduction with sequential addressing
__global__ void reduce_shared(const float* in, float* out, int N) {
    __shared__ float sdata[BLOCK_SIZE];
    int tid = threadIdx.x;
    int gid = blockIdx.x * blockDim.x + tid;

    sdata[tid] = (gid < N) ? in[gid] : 0.0f;
    __syncthreads();

    // Tree reduction with sequential addressing (no bank conflicts)
    for (int stride = blockDim.x / 2; stride > 0; stride /= 2) {
        if (tid < stride) {
            sdata[tid] += sdata[tid + stride];
        }
        __syncthreads();
    }

    if (tid == 0) atomicAdd(out, sdata[0]);
}

// Intra-warp reduction using warp shuffle (5 instructions)
__inline__ __device__ float warpReduceSum(float val) {
    for (int offset = 16; offset > 0; offset /= 2) {
        val += __shfl_down_sync(0xffffffff, val, offset);
    }
    return val;
}

// Implementation B: Warp-shuffle reduction
__global__ void reduce_shuffle(const float* in, float* out, int N) {
    int tid = threadIdx.x;
    int gid = blockIdx.x * blockDim.x + tid;

    float val = (gid < N) ? in[gid] : 0.0f;

    // Step 1: intra-warp reduction via shuffle (32 -> 1)
    val = warpReduceSum(val);

    // Step 2: cross-warp reduction via shared memory
    __shared__ float warp_sums[32];
    int lane = tid % 32;
    int warp_id = tid / 32;
    if (lane == 0) warp_sums[warp_id] = val;
    __syncthreads();

    // Step 3: first warp reduces warp_sums
    if (warp_id == 0) {
        int num_warps = blockDim.x / 32;
        val = (lane < num_warps) ? warp_sums[lane] : 0.0f;
        val = warpReduceSum(val);
        if (lane == 0) atomicAdd(out, val);
    }
}

// Golden Kahan summation CPU reference (using double for numerical stability)
double kahan_sum(const float* in, int N) {
    double sum = 0.0, c = 0.0;
    for (int i = 0; i < N; ++i) {
        double y = (double)in[i] - c;
        double t = sum + y;
        c = (t - sum) - y;
        sum = t;
    }
    return sum;
}

int main(int argc, char* argv[]) {
    int N = DEFAULT_N;
    if (argc > 1) {
        N = atoi(argv[1]);
        if (N <= 0) N = DEFAULT_N;
    }

    int deviceId = 0;
    cudaGetDevice(&deviceId);
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, deviceId);

    double peak_bandwidth_GB_s = T4_PEAK_BANDWIDTH_GB_S;
    size_t bytes = (size_t)N * sizeof(float);

    printf("============================================================\n");
    printf("Exercise 4: Warp Shuffle Reduction\n");
    printf("============================================================\n");
    printf("GPU Device: %s (Compute Capability %d.%d)\n", prop.name, prop.major, prop.minor);
    printf("Theoretical Peak Memory Bandwidth (T4 spec): %.1f GB/s\n", peak_bandwidth_GB_s);
    printf("Number of Elements: %d (%.2f M elements, %.2f MB)\n",
           N, (double)N / (1024.0 * 1024.0), (double)bytes / (1024.0 * 1024.0));
    printf("============================================================\n\n");

    // Allocate and initialize host memory
    printf("Allocating and initializing host memory (N=%d)...\n", N);
    float* h_in = (float*)malloc(bytes);
    if (!h_in) {
        fprintf(stderr, "Host memory allocation failed\n");
        return 1;
    }

    srand(42);
    for (int i = 0; i < N; ++i) {
        h_in[i] = 2.0f * (float)rand() / (float)RAND_MAX;
    }

    // Golden CPU reference sum
    printf("Computing CPU reference sum via Kahan summation...\n");
    double cpu_result = kahan_sum(h_in, N);
    printf("CPU Reference Sum: %.6f\n\n", cpu_result);

    // Allocate device memory
    float *d_in = NULL, *d_out = NULL;
    cudaMalloc((void**)&d_in, bytes);
    cudaMalloc((void**)&d_out, sizeof(float));

    cudaMemcpy(d_in, h_in, bytes, cudaMemcpyHostToDevice);

    dim3 block(BLOCK_SIZE);
    dim3 grid((N + BLOCK_SIZE - 1) / BLOCK_SIZE);
    printf("Launch configuration: Block size = %d, Grid size = %d blocks\n\n", block.x, grid.x);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // -------------------------------------------------------------
    // Implementation A: Standard Shared-Memory Reduction
    // -------------------------------------------------------------
    printf("--- Benchmarking Implementation A: Shared Memory Reduction ---\n");
    // Warm-up
    cudaMemset(d_out, 0, sizeof(float));
    reduce_shared<<<grid, block>>>(d_in, d_out, N);
    cudaDeviceSynchronize();

    float shared_total_ms = 0.0f;
    for (int trial = 0; trial < NUM_TRIALS; ++trial) {
        cudaMemset(d_out, 0, sizeof(float));
        cudaEventRecord(start);
        reduce_shared<<<grid, block>>>(d_in, d_out, N);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float ms = 0.0f;
        cudaEventElapsedTime(&ms, start, stop);
        printf("  Shared Trial %d: %.3f ms\n", trial + 1, ms);
        shared_total_ms += ms;
    }
    float shared_avg_ms = shared_total_ms / NUM_TRIALS;
    double shared_bw = ((double)N * sizeof(float)) / (shared_avg_ms * 1e-3) / 1e9;

    float gpu_shared_res = 0.0f;
    cudaMemcpy(&gpu_shared_res, d_out, sizeof(float), cudaMemcpyDeviceToHost);
    double shared_rel_err = fabs((double)gpu_shared_res - cpu_result) / fabs(cpu_result);
    printf("  GPU Result: %.6f, Rel Error: %.6e (%s)\n\n",
           gpu_shared_res, shared_rel_err, (shared_rel_err < 1e-3) ? "PASSED" : "FAILED");

    // -------------------------------------------------------------
    // Implementation B: Warp-Shuffle Reduction
    // -------------------------------------------------------------
    printf("--- Benchmarking Implementation B: Warp Shuffle Reduction ---\n");
    // Warm-up
    cudaMemset(d_out, 0, sizeof(float));
    reduce_shuffle<<<grid, block>>>(d_in, d_out, N);
    cudaDeviceSynchronize();

    float shuffle_total_ms = 0.0f;
    for (int trial = 0; trial < NUM_TRIALS; ++trial) {
        cudaMemset(d_out, 0, sizeof(float));
        cudaEventRecord(start);
        reduce_shuffle<<<grid, block>>>(d_in, d_out, N);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float ms = 0.0f;
        cudaEventElapsedTime(&ms, start, stop);
        printf("  Shuffle Trial %d: %.3f ms\n", trial + 1, ms);
        shuffle_total_ms += ms;
    }
    float shuffle_avg_ms = shuffle_total_ms / NUM_TRIALS;
    double shuffle_bw = ((double)N * sizeof(float)) / (shuffle_avg_ms * 1e-3) / 1e9;
    double speedup = shared_avg_ms / shuffle_avg_ms;

    float gpu_shuffle_res = 0.0f;
    cudaMemcpy(&gpu_shuffle_res, d_out, sizeof(float), cudaMemcpyDeviceToHost);
    double shuffle_rel_err = fabs((double)gpu_shuffle_res - cpu_result) / fabs(cpu_result);
    printf("  GPU Result: %.6f, Rel Error: %.6e (%s)\n\n",
           gpu_shuffle_res, shuffle_rel_err, (shuffle_rel_err < 1e-3) ? "PASSED" : "FAILED");

    // -------------------------------------------------------------
    // Summary Table (as requested by Lab report)
    // -------------------------------------------------------------
    printf("========================================================================================\n");
    printf("%-20s %-15s %-18s %-18s %-12s\n", "variant", "time (ms)", "bandwidth (GB/s)", "speedup vs shared", "% of peak");
    printf("----------------------------------------------------------------------------------------\n");
    printf("%-20s %-15.3f %-18.2f %-18.2f %-12.2f%%\n",
           "shared mem", shared_avg_ms, shared_bw, 1.00, (shared_bw / peak_bandwidth_GB_s) * 100.0);
    printf("%-20s %-15.3f %-18.2f %-18.2f %-12.2f%%\n",
           "warp shuffle", shuffle_avg_ms, shuffle_bw, speedup, (shuffle_bw / peak_bandwidth_GB_s) * 100.0);
    printf("========================================================================================\n");

    // Cleanup
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_in);
    cudaFree(d_out);
    free(h_in);

    return 0;
}
