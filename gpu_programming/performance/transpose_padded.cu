#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEFAULT_N 8192
#define TILE_DIM 32
#define NUM_TRIALS 5

// Peak bandwidth for Tesla T4 is ~320.0 GB/s (from spec sheet / Week 4 lab)
#define T4_PEAK_BANDWIDTH_GB_S 320.0

// 1. Naive matrix transpose kernel: coalesced reads, uncoalesced (strided) writes
__global__ void transpose_naive(float* out, const float* in, int N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < N && col < N) {
        out[col * N + row] = in[row * N + col];
    }
}

// 2. Coalesced matrix transpose kernel without padding (has 32-way shared memory bank conflicts)
__global__ void transpose_coalesced(float* out, const float* in, int N) {
    __shared__ float tile[TILE_DIM][TILE_DIM];

    int in_x = blockIdx.x * TILE_DIM + threadIdx.x;
    int in_y = blockIdx.y * TILE_DIM + threadIdx.y;

    if (in_x < N && in_y < N) {
        tile[threadIdx.y][threadIdx.x] = in[in_y * N + in_x];
    }

    __syncthreads();

    int out_x = blockIdx.y * TILE_DIM + threadIdx.x;
    int out_y = blockIdx.x * TILE_DIM + threadIdx.y;

    if (out_x < N && out_y < N) {
        out[out_y * N + out_x] = tile[threadIdx.x][threadIdx.y];
    }
}

// 3. Coalesced matrix transpose kernel WITH padding (+1 column eliminates bank conflicts)
__global__ void transpose_padded(float* out, const float* in, int N) {
    __shared__ float tile[TILE_DIM][TILE_DIM + 1];

    int in_x = blockIdx.x * TILE_DIM + threadIdx.x;
    int in_y = blockIdx.y * TILE_DIM + threadIdx.y;

    if (in_x < N && in_y < N) {
        tile[threadIdx.y][threadIdx.x] = in[in_y * N + in_x];
    }

    __syncthreads();

    int out_x = blockIdx.y * TILE_DIM + threadIdx.x;
    int out_y = blockIdx.x * TILE_DIM + threadIdx.y;

    if (out_x < N && out_y < N) {
        out[out_y * N + out_x] = tile[threadIdx.x][threadIdx.y];
    }
}

// CPU gold reference transpose
void transpose_cpu(float* out, const float* in, int N) {
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            out[j * N + i] = in[i * N + j];
        }
    }
}

// Helper to initialize matrix
void init_matrix(float* mat, int N) {
    for (int i = 0; i < N * N; ++i) {
        mat[i] = (float)(i % 1000) * 0.001f;
    }
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

    printf("============================================================\n");
    printf("Exercise 3: Bank Conflict Elimination (Padded Shared Memory)\n");
    printf("============================================================\n");
    printf("GPU Device: %s (Compute Capability %d.%d)\n", prop.name, prop.major, prop.minor);
    printf("Theoretical Peak Memory Bandwidth (T4 spec): %.1f GB/s\n", peak_bandwidth_GB_s);
    printf("Matrix Dimension: %d x %d (%zu elements)\n", N, N, (size_t)N * N);
    size_t matrix_bytes = (size_t)N * N * sizeof(float);
    printf("Memory per matrix: %.2f MB (Total for in + out: %.2f MB)\n",
           matrix_bytes / (1024.0 * 1024.0), (2.0 * matrix_bytes) / (1024.0 * 1024.0));
    printf("============================================================\n\n");

    // Allocate host memory
    printf("Allocating host memory...\n");
    float* h_in = (float*)malloc(matrix_bytes);
    float* h_gpu_out = (float*)malloc(matrix_bytes);
    float* h_cpu_out = (float*)malloc(matrix_bytes);
    if (!h_in || !h_gpu_out || !h_cpu_out) {
        fprintf(stderr, "Host memory allocation failed\n");
        return 1;
    }

    printf("Initializing input matrix...\n");
    init_matrix(h_in, N);

    // Compute CPU golden reference transpose
    printf("Computing CPU golden reference transpose...\n");
    transpose_cpu(h_cpu_out, h_in, N);

    // Allocate device memory
    printf("Allocating device memory...\n");
    float *d_in = NULL, *d_out = NULL;
    cudaMalloc((void**)&d_in, matrix_bytes);
    cudaMalloc((void**)&d_out, matrix_bytes);

    cudaMemcpy(d_in, h_in, matrix_bytes, cudaMemcpyHostToDevice);

    dim3 block(TILE_DIM, TILE_DIM); // 32 x 32 = 1024 threads
    dim3 grid((N + TILE_DIM - 1) / TILE_DIM, (N + TILE_DIM - 1) / TILE_DIM);
    printf("Launch configuration: Block (%d, %d), Grid (%d, %d)\n\n",
           block.x, block.y, grid.x, grid.y);

    // Timing events
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    double total_bytes = 2.0 * (double)N * (double)N * sizeof(float);

    // -------------------------------------------------------------
    // Benchmark 1: Naive Transpose
    // -------------------------------------------------------------
    printf("--- Benchmarking Variant 1: Naive Transpose ---\n");
    transpose_naive<<<grid, block>>>(d_out, d_in, N);
    cudaDeviceSynchronize();

    float naive_total_ms = 0.0f;
    for (int trial = 0; trial < NUM_TRIALS; ++trial) {
        cudaEventRecord(start);
        transpose_naive<<<grid, block>>>(d_out, d_in, N);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float ms = 0.0f;
        cudaEventElapsedTime(&ms, start, stop);
        printf("  Naive Trial %d: %.3f ms\n", trial + 1, ms);
        naive_total_ms += ms;
    }
    float naive_avg_ms = naive_total_ms / NUM_TRIALS;
    double naive_bw = total_bytes / (naive_avg_ms * 1e-3) / 1e9;

    cudaMemcpy(h_gpu_out, d_out, matrix_bytes, cudaMemcpyDeviceToHost);
    printf("  Verification: %s\n\n", (memcmp(h_cpu_out, h_gpu_out, matrix_bytes) == 0) ? "PASSED" : "FAILED");
    cudaMemset(d_out, 0, matrix_bytes);

    // -------------------------------------------------------------
    // Benchmark 2: Coalesced Transpose (No Padding)
    // -------------------------------------------------------------
    printf("--- Benchmarking Variant 2: Coalesced (Unpadded) ---\n");
    transpose_coalesced<<<grid, block>>>(d_out, d_in, N);
    cudaDeviceSynchronize();

    float coalesced_total_ms = 0.0f;
    for (int trial = 0; trial < NUM_TRIALS; ++trial) {
        cudaEventRecord(start);
        transpose_coalesced<<<grid, block>>>(d_out, d_in, N);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float ms = 0.0f;
        cudaEventElapsedTime(&ms, start, stop);
        printf("  Coalesced Trial %d: %.3f ms\n", trial + 1, ms);
        coalesced_total_ms += ms;
    }
    float coalesced_avg_ms = coalesced_total_ms / NUM_TRIALS;
    double coalesced_bw = total_bytes / (coalesced_avg_ms * 1e-3) / 1e9;

    cudaMemcpy(h_gpu_out, d_out, matrix_bytes, cudaMemcpyDeviceToHost);
    printf("  Verification: %s\n\n", (memcmp(h_cpu_out, h_gpu_out, matrix_bytes) == 0) ? "PASSED" : "FAILED");
    cudaMemset(d_out, 0, matrix_bytes);

    // -------------------------------------------------------------
    // Benchmark 3: Coalesced Transpose + Padded (No Bank Conflicts)
    // -------------------------------------------------------------
    printf("--- Benchmarking Variant 3: Coalesced + Padded (+1 Column) ---\n");
    transpose_padded<<<grid, block>>>(d_out, d_in, N);
    cudaDeviceSynchronize();

    float padded_total_ms = 0.0f;
    for (int trial = 0; trial < NUM_TRIALS; ++trial) {
        cudaEventRecord(start);
        transpose_padded<<<grid, block>>>(d_out, d_in, N);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float ms = 0.0f;
        cudaEventElapsedTime(&ms, start, stop);
        printf("  Padded Trial %d: %.3f ms\n", trial + 1, ms);
        padded_total_ms += ms;
    }
    float padded_avg_ms = padded_total_ms / NUM_TRIALS;
    double padded_bw = total_bytes / (padded_avg_ms * 1e-3) / 1e9;

    cudaMemcpy(h_gpu_out, d_out, matrix_bytes, cudaMemcpyDeviceToHost);
    printf("  Verification: %s\n\n", (memcmp(h_cpu_out, h_gpu_out, matrix_bytes) == 0) ? "PASSED" : "FAILED");

    // -------------------------------------------------------------
    // Summary Table (All 3 Variants)
    // -------------------------------------------------------------
    printf("========================================================================================\n");
    printf("%-24s %-12s %-18s %-18s %-12s\n", "variant", "time (ms)", "bandwidth (GB/s)", "speedup vs naive", "% of peak");
    printf("----------------------------------------------------------------------------------------\n");
    printf("%-24s %-12.3f %-18.2f %-18.2f %-12.2f%%\n",
           "naive", naive_avg_ms, naive_bw, 1.00, (naive_bw / peak_bandwidth_GB_s) * 100.0);
    printf("%-24s %-12.3f %-18.2f %-18.2f %-12.2f%%\n",
           "coalesced", coalesced_avg_ms, coalesced_bw, naive_avg_ms / coalesced_avg_ms, (coalesced_bw / peak_bandwidth_GB_s) * 100.0);
    printf("%-24s %-12.3f %-18.2f %-18.2f %-12.2f%%\n",
           "coalesced + padded", padded_avg_ms, padded_bw, naive_avg_ms / padded_avg_ms, (padded_bw / peak_bandwidth_GB_s) * 100.0);
    printf("========================================================================================\n");
    printf("Padded vs Coalesced Speedup: %.2fx (%.1f%% improvement)\n",
           coalesced_avg_ms / padded_avg_ms, ((coalesced_avg_ms - padded_avg_ms) / coalesced_avg_ms) * 100.0);
    printf("========================================================================================\n");

    // Cleanup
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_in);
    cudaFree(d_out);
    free(h_in);
    free(h_gpu_out);
    free(h_cpu_out);

    return 0;
}
