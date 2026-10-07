#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEFAULT_N 8192
#define TILE_DIM 32
#define NUM_TRIALS 5

// Peak bandwidth for Tesla T4 is ~320.0 GB/s (from spec sheet / Week 4 lab)
#define T4_PEAK_BANDWIDTH_GB_S 320.0

// Naive matrix transpose kernel: coalesced reads, uncoalesced (strided) writes
__global__ void transpose_naive(float* out, const float* in, int N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < N && col < N) {
        out[col * N + row] = in[row * N + col];
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
    printf("Exercise 1: Roofline Positioning of Naive Transpose\n");
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

    // Allocate device memory
    printf("Allocating device memory...\n");
    float *d_in = NULL, *d_out = NULL;
    cudaMalloc((void**)&d_in, matrix_bytes);
    cudaMalloc((void**)&d_out, matrix_bytes);

    cudaMemcpy(d_in, h_in, matrix_bytes, cudaMemcpyHostToDevice);

    // Kernel launch configuration
    dim3 block(TILE_DIM, TILE_DIM); // 32 x 32 = 1024 threads
    dim3 grid((N + TILE_DIM - 1) / TILE_DIM, (N + TILE_DIM - 1) / TILE_DIM);
    printf("Launch configuration: Block (%d, %d), Grid (%d, %d)\n",
           block.x, block.y, grid.x, grid.y);

    // Warm-up iteration
    printf("Running warm-up kernel launch...\n");
    transpose_naive<<<grid, block>>>(d_out, d_in, N);
    cudaDeviceSynchronize();

    // Timing events
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    printf("Benchmarking naive transpose over %d trials...\n", NUM_TRIALS);
    float total_ms = 0.0f;
    for (int trial = 0; trial < NUM_TRIALS; ++trial) {
        cudaEventRecord(start);
        transpose_naive<<<grid, block>>>(d_out, d_in, N);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float trial_ms = 0.0f;
        cudaEventElapsedTime(&trial_ms, start, stop);
        printf("  Trial %d: %.3f ms\n", trial + 1, trial_ms);
        total_ms += trial_ms;
    }

    float avg_ms = total_ms / NUM_TRIALS;
    // Total data moved: 1 read + 1 write = 2 * N * N * sizeof(float)
    double total_bytes = 2.0 * (double)N * (double)N * sizeof(float);
    double bandwidth_GB_s = total_bytes / (avg_ms * 1e-3) / 1e9;
    double pct_peak = (bandwidth_GB_s / peak_bandwidth_GB_s) * 100.0;

    printf("\n--- Performance Results ---\n");
    printf("Average Kernel Time: %.3f ms\n", avg_ms);
    printf("Effective Bandwidth: %.2f GB/s\n", bandwidth_GB_s);
    printf("Percentage of Peak Bandwidth: %.2f %%\n", pct_peak);

    // Copy result back for correctness verification
    printf("\n--- Correctness Verification ---\n");
    cudaMemcpy(h_gpu_out, d_out, matrix_bytes, cudaMemcpyDeviceToHost);

    printf("Computing CPU golden reference transpose...\n");
    transpose_cpu(h_cpu_out, h_in, N);

    // Exact bitwise comparison
    int cmp_result = memcmp(h_cpu_out, h_gpu_out, matrix_bytes);
    if (cmp_result == 0) {
        printf("Verification PASSED: GPU output exactly matches CPU output (memcmp returned 0).\n");
    } else {
        printf("Verification FAILED: Differences detected!\n");
        int errors = 0;
        for (int i = 0; i < N * N; ++i) {
            if (h_cpu_out[i] != h_gpu_out[i]) {
                if (errors < 5) {
                    int r = i / N;
                    int c = i % N;
                    printf("  Mismatch at [%d, %d]: CPU = %f, GPU = %f\n",
                           r, c, h_cpu_out[i], h_gpu_out[i]);
                }
                errors++;
            }
        }
        printf("Total mismatches: %d\n", errors);
    }

    // Spot-check samples
    printf("Sample spot-check (matrix corners):\n");
    printf("  in[0, 0] = %f  -> out[0, 0] = %f\n", h_in[0], h_gpu_out[0]);
    printf("  in[0, 1] = %f  -> out[1, 0] = %f\n", h_in[1], h_gpu_out[1 * N + 0]);
    printf("  in[1, 0] = %f  -> out[0, 1] = %f\n", h_in[1 * N + 0], h_gpu_out[0 * N + 1]);
    printf("  in[N-1, N-1] = %f -> out[N-1, N-1] = %f\n",
           h_in[(N - 1) * N + (N - 1)], h_gpu_out[(N - 1) * N + (N - 1)]);

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
