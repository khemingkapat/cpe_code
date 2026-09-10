#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

__global__ void matmul_naive(const float* A, const float* B,
                              float* C, int N)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < N && col < N) {
        float sum = 0.0f;
        for (int k = 0; k < N; ++k) {
            sum += A[row * N + k] * B[k * N + col];
        }
        C[row * N + col] = sum;
    }
}

void matmul_cpu(const float* A, const float* B, float* C, int N) {
    for (int i = 0; i < N; ++i)
      for (int j = 0; j < N; ++j) {
        double sum = 0.0;   // note: double to reduce reference error
        for (int k = 0; k < N; ++k)
          sum += (double)A[i*N+k] * (double)B[k*N+j];
        C[i*N+j] = (float)sum;
      }
}

bool verify(const float* cpu, const float* gpu, int N, float tol) {
    float max_rel_err = 0.0f;
    for (int i = 0; i < N * N; ++i) {
        float diff  = fabsf(cpu[i] - gpu[i]);
        float denom = fabsf(cpu[i]) + 1e-6f;   // avoid div-by-zero
        float rel   = diff / denom;
        if (rel > max_rel_err) max_rel_err = rel;
    }
    printf("Max relative error: %e\n", max_rel_err);
    return max_rel_err < tol;
}

int main() {
    const int N = 2048;
    const size_t bytes = N * N * sizeof(float);
    const float tol = 1e-3f;

    // Allocate host memory
    float* h_A = (float*)malloc(bytes);
    float* h_B = (float*)malloc(bytes);
    float* h_C_cpu = (float*)malloc(bytes);
    float* h_C_gpu = (float*)malloc(bytes);

    // Initialize inputs
    srand(42);
    for (int i = 0; i < N * N; ++i) {
        h_A[i] = (rand() / (float)RAND_MAX) * 2.0f - 1.0f;
        h_B[i] = (rand() / (float)RAND_MAX) * 2.0f - 1.0f;
    }

    // Allocate device memory
    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);

    // Copy to device
    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    // Launch configuration
    dim3 block(16, 16);
    dim3 grid((N + block.x - 1) / block.x, (N + block.y - 1) / block.y);

    // Warm up
    matmul_naive<<<grid, block>>>(d_A, d_B, d_C, N);
    cudaDeviceSynchronize();

    // Timing with CUDA events
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int trial = 0; trial < 5; ++trial) {
        matmul_naive<<<grid, block>>>(d_A, d_B, d_C, N);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    float ms_per_trial = ms / 5.0f;

    // Copy result back
    cudaMemcpy(h_C_gpu, d_C, bytes, cudaMemcpyDeviceToHost);

    // Verification
    matmul_cpu(h_A, h_B, h_C_cpu, N);
    verify(h_C_cpu, h_C_gpu, N, tol);

    // Performance calculation
    double flops = 2.0 * N * N * N;
    double gflops = flops / (ms_per_trial * 1e-3) / 1e9;
    printf("Average Time: %.3f ms | Performance: %.2f GFLOPS\n", ms_per_trial, gflops);

    // Cleanup
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    free(h_A);
    free(h_B);
    free(h_C_cpu);
    free(h_C_gpu);

    return 0;
}
