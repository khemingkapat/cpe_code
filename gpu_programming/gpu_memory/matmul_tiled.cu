#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

template <int TILE_WIDTH>
__global__ void matmul_tiled(const float* A, const float* B,
                              float* C, int N)
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

void matmul_cpu(const float* A, const float* B, float* C, int N) {
    for (int i = 0; i < N; ++i)
      for (int j = 0; j < N; ++j) {
        double sum = 0.0;
        for (int k = 0; k < N; ++k)
          sum += (double)A[i*N+k] * (double)B[k*N+j];
        C[i*N+j] = (float)sum;
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
    printf("Max relative error: %e\n", max_rel_err);
    return max_rel_err < tol;
}

template <int TILE_WIDTH>
void run_test(int N) {
    printf("\n=== N = %d, TILE_WIDTH = %d ===\n", N, TILE_WIDTH);

    const size_t bytes = N * N * sizeof(float);
    const float tol = 1e-3f;

    float* h_A = (float*)malloc(bytes);
    float* h_B = (float*)malloc(bytes);
    float* h_C_cpu = (float*)malloc(bytes);
    float* h_C_gpu = (float*)malloc(bytes);

    srand(42);
    for (int i = 0; i < N * N; ++i) {
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

    // Warm up
    matmul_tiled<TILE_WIDTH><<<grid, block>>>(d_A, d_B, d_C, N);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int trial = 0; trial < 5; ++trial) {
        matmul_tiled<TILE_WIDTH><<<grid, block>>>(d_A, d_B, d_C, N);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    float ms_per_trial = ms / 5.0f;

    cudaMemcpy(h_C_gpu, d_C, bytes, cudaMemcpyDeviceToHost);

    matmul_cpu(h_A, h_B, h_C_cpu, N);
    verify(h_C_cpu, h_C_gpu, N, tol);

    double flops = 2.0 * N * N * N;
    double gflops = flops / (ms_per_trial * 1e-3) / 1e9;
    printf("Average Time: %.3f ms | Performance: %.2f GFLOPS\n", ms_per_trial, gflops);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    free(h_A);
    free(h_B);
    free(h_C_cpu);
    free(h_C_gpu);
}

int main() {
    run_test<8>(2048);
    run_test<16>(2048);
    run_test<32>(2048);

    run_test<16>(4096);

    return 0;
}
