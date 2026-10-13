#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define TILE_WIDTH 16

__global__ void matmul_tiled(const float* A, const float* B, float* C, int N)
{
    __shared__ float subTileA[TILE_WIDTH][TILE_WIDTH];
    __shared__ float subTileB[TILE_WIDTH][TILE_WIDTH];

    int bx = blockIdx.x, by = blockIdx.y;
    int tx = threadIdx.x, ty = threadIdx.y;

    int Row = by * TILE_WIDTH + ty;
    int Col = bx * TILE_WIDTH + tx;
    float Pvalue = 0.0f;

    for (int m = 0; m < N / TILE_WIDTH; ++m) {
        subTileA[ty][tx] = A[Row * N + m * TILE_WIDTH + tx];
        subTileB[ty][tx] = B[(m * TILE_WIDTH + ty) * N + Col];
        __syncthreads();

        for (int k = 0; k < TILE_WIDTH; ++k) {
            Pvalue += subTileA[ty][k] * subTileB[k][tx];
        }
        __syncthreads();
    }
    C[Row * N + Col] = Pvalue;
}

__global__ void matmul_tiled_bad(const float* A, const float* B, float* C, int N)
{
    __shared__ float subTileA[TILE_WIDTH][TILE_WIDTH];
    __shared__ float subTileB[TILE_WIDTH][TILE_WIDTH];

    int bx = blockIdx.x, by = blockIdx.y;
    int tx = threadIdx.x, ty = threadIdx.y;

    int Row = by * TILE_WIDTH + ty;
    int Col = bx * TILE_WIDTH + tx;
    float Pvalue = 0.0f;

    for (int m = 0; m < N / TILE_WIDTH; ++m) {
        // Uncoalesced read pattern into shared memory
        subTileA[tx][ty] = A[(by * TILE_WIDTH + tx) * N + m * TILE_WIDTH + ty];
        subTileB[ty][tx] = B[(m * TILE_WIDTH + ty) * N + Col];
        __syncthreads();

        for (int k = 0; k < TILE_WIDTH; ++k) {
            Pvalue += subTileA[ty][k] * subTileB[k][tx];
        }
        __syncthreads();
    }
    C[Row * N + Col] = Pvalue;
}

// Simple benchmark function for matmul_tiled
float benchmark_tiled(const float* d_A, const float* d_B, float* d_C,
                      int N, dim3 grid, dim3 block)
{
    matmul_tiled<<<grid, block>>>(d_A, d_B, d_C, N);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    const int trials = 10;
    cudaEventRecord(start);
    for (int i = 0; i < trials; ++i) {
        matmul_tiled<<<grid, block>>>(d_A, d_B, d_C, N);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float total_ms = 0.0f;
    cudaEventElapsedTime(&total_ms, start, stop);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return total_ms / trials;
}

float benchmark_tiled_bad(const float* d_A, const float* d_B, float* d_C,
                          int N, dim3 grid, dim3 block)
{
    matmul_tiled_bad<<<grid, block>>>(d_A, d_B, d_C, N);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    const int trials = 10;
    cudaEventRecord(start);
    for (int i = 0; i < trials; ++i) {
        matmul_tiled_bad<<<grid, block>>>(d_A, d_B, d_C, N);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float total_ms = 0.0f;
    cudaEventElapsedTime(&total_ms, start, stop);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return total_ms / trials;
}

int main() {
    const int N = 2048;
    const size_t bytes = N * N * sizeof(float);

    float *h_A = (float*)malloc(bytes);
    float *h_B = (float*)malloc(bytes);
    float *h_C = (float*)malloc(bytes);

    for (int i = 0; i < N * N; ++i) {
        h_A[i] = 1.0f;
        h_B[i] = 1.0f;
    }

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);

    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    dim3 block(TILE_WIDTH, TILE_WIDTH);
    dim3 grid(N / TILE_WIDTH, N / TILE_WIDTH);
    printf("Running benchmark: N = %d, TILE_WIDTH = %d\n", N, TILE_WIDTH);
    printf("Note: Numerical correctness verification is omitted for this comparison.\n\n");

    float time_good = benchmark_tiled(d_A, d_B, d_C, N, grid, block);
    printf("Coalesced kernel avg time:   %f ms\n", time_good);

    float time_bad = benchmark_tiled_bad(d_A, d_B, d_C, N, grid, block);
    printf("Uncoalesced kernel avg time: %f ms\n", time_bad);

    double flops = 2.0 * (double)N * (double)N * (double)N;
    double gflops_good = flops / (time_good * 1e-3) / 1e9;
    double gflops_bad  = flops / (time_bad  * 1e-3) / 1e9;
 
    printf("matmul_tiled (Coalesced):    %.3f ms | %.2f GFLOPS\n", time_good, gflops_good);
    printf("matmul_tiled_bad (Uncoalesced): %.3f ms | %.2f GFLOPS\n", time_bad, gflops_bad);
    printf("Slowdown factor:              %.2fx\n", time_bad / time_good);
 

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}
