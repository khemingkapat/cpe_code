#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

__global__ void matmul_tiled_bounded(const float* A, const float* B,
                                     float* C, int N, int TILE_WIDTH)
{
    extern __shared__ float shared_mem[];
    float* subTileA = shared_mem;
    float* subTileB = shared_mem + TILE_WIDTH * TILE_WIDTH;

    int bx = blockIdx.x, by = blockIdx.y;
    int tx = threadIdx.x, ty = threadIdx.y;

    int Row = by * TILE_WIDTH + ty;
    int Col = bx * TILE_WIDTH + tx;
    float Pvalue = 0.0f;

    int numTiles = (N + TILE_WIDTH - 1) / TILE_WIDTH;

    for (int m = 0; m < numTiles; ++m) {
        int a_col = m * TILE_WIDTH + tx;
        int b_row = m * TILE_WIDTH + ty;

        // Guard for loading subTileA
        if (Row < N && a_col < N) {
            subTileA[ty * TILE_WIDTH + tx] = A[Row * N + a_col];
        } else {
            subTileA[ty * TILE_WIDTH + tx] = 0.0f;
        }

        // Guard for loading subTileB
        if (b_row < N && Col < N) {
            subTileB[ty * TILE_WIDTH + tx] = B[b_row * N + Col];
        } else {
            subTileB[ty * TILE_WIDTH + tx] = 0.0f;
        }
        __syncthreads();

        for (int k = 0; k < TILE_WIDTH; ++k) {
            Pvalue += subTileA[ty * TILE_WIDTH + k] * subTileB[k * TILE_WIDTH + tx];
        }
        __syncthreads();
    }

    // Guard for final write
    if (Row < N && Col < N) {
        C[Row * N + Col] = Pvalue;
    }
}

void matmul_cpu(const float* A, const float* B, float* C, int N) {
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            double sum = 0.0;
            for (int k = 0; k < N; ++k) {
                sum += (double)A[i * N + k] * (double)B[k * N + j];
            }
            C[i * N + j] = (float)sum;
        }
    }
}

bool verify(const float* cpu, const float* gpu, int N, float tol) {
    float max_rel_err = 0.0f;
    for (int i = 0; i < N * N; ++i) {
        float diff  = fabsf(cpu[i] - gpu[i]);
        float denom = fabsf(cpu[i]) + 1e-6f;
        float rel   = diff / denom;
        if (rel > max_rel_err) max_rel_err = rel;
    }
    printf("Max relative error: %e -> %s\n", max_rel_err, (max_rel_err < tol) ? "PASSED" : "FAILED");
    return max_rel_err < tol;
}

float run_test(int N, int TILE_WIDTH, bool run_verification) {
    printf("\n=== N = %d, TILE_WIDTH = %d ===\n", N, TILE_WIDTH);

    const size_t bytes = (size_t)N * N * sizeof(float);
    const float tol = 1e-3f;

    float* h_A = (float*)malloc(bytes);
    float* h_B = (float*)malloc(bytes);
    float* h_C_cpu = run_verification ? (float*)malloc(bytes) : NULL;
    float* h_C_gpu = (float*)malloc(bytes);

    srand(42);
    for (size_t i = 0; i < (size_t)N * N; ++i) {
        h_A[i] = (rand() / (float)RAND_MAX) * 2.0f - 1.0f;
        h_B[i] = (rand() / (float)RAND_MAX) * 2.0f - 1.0f;
    }

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);

    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    dim3 block(TILE_WIDTH, TILE_WIDTH);
    dim3 grid((N + block.x - 1) / block.x, (N + block.y - 1) / block.y);
    size_t shared_bytes = 2 * TILE_WIDTH * TILE_WIDTH * sizeof(float);

    // Warm up
    matmul_tiled_bounded<<<grid, block, shared_bytes>>>(d_A, d_B, d_C, N, TILE_WIDTH);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    const int trials = 5;
    for (int trial = 0; trial < trials; ++trial) {
        matmul_tiled_bounded<<<grid, block, shared_bytes>>>(d_A, d_B, d_C, N, TILE_WIDTH);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    float ms_per_trial = ms / (float)trials;

    cudaMemcpy(h_C_gpu, d_C, bytes, cudaMemcpyDeviceToHost);

    if (run_verification) {
        printf("Running CPU reference verification...\n");
        matmul_cpu(h_A, h_B, h_C_cpu, N);
        verify(h_C_cpu, h_C_gpu, N, tol);
    }

    double flops = 2.0 * (double)N * (double)N * (double)N;
    double gflops = flops / (ms_per_trial * 1e-3) / 1e9;
    printf("Average Time: %.3f ms | Performance: %.2f GFLOPS\n", ms_per_trial, gflops);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    free(h_A);
    free(h_B);
    if (h_C_cpu) free(h_C_cpu);
    free(h_C_gpu);

    return ms_per_trial;
}

int main() {
    const int TILE_WIDTH = 16;

    // 1. Correctness verification on required dimensions
    printf("--- Phase 1: Correctness Verification ---\n");
    run_test(1000, TILE_WIDTH, true);
    run_test(1023, TILE_WIDTH, true);
    run_test(1025, TILE_WIDTH, true);

    // 2. Boundary overhead measurement
    printf("\n--- Phase 2: Boundary Overhead Measurement ---\n");
    float time_1024 = run_test(1024, TILE_WIDTH, false);
    float time_1000 = run_test(1000, TILE_WIDTH, false);

    float overhead = (time_1000 / time_1024) - 1.0f;
    printf("\nTiming Summary:\n");
    printf("Time (N=1024): %.3f ms\n", time_1024);
    printf("Time (N=1000): %.3f ms\n", time_1000);
    printf("Boundary Overhead: %.2f%%\n", overhead * 100.0f);

    return 0;
}
