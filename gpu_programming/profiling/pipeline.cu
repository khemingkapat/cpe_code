#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define CHECK_CUDA(call)                                                     \
    do {                                                                     \
        cudaError_t err = call;                                              \
        if (err != cudaSuccess) {                                            \
            fprintf(stderr, "CUDA error at %s:%d: %s\n", __FILE__, __LINE__, \
                    cudaGetErrorString(err));                                \
            exit(EXIT_FAILURE);                                              \
        }                                                                    \
    } while (0)

__global__ void fast_kernel(float* d, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) d[i] = d[i] * 1.5f;
}

__global__ void slow_kernel(float* d, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        float v = d[i];
        for (int k = 0; k < 5000; ++k) v = v * 1.0001f + 0.001f;
        d[i] = v;
    }
}

__global__ void medium_kernel(float* d, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        float v = d[i];
        for (int k = 0; k < 500; ++k) v = v * 1.0001f + 0.001f;
        d[i] = v;
    }
}

int main(int argc, char** argv) {
    const int N = 16 * 1024 * 1024; // 16M elements (~64 MB)
    const int block_size = 256;
    const int grid_size = (N + block_size - 1) / block_size;
    size_t bytes = N * sizeof(float);

    printf("Initializing 3-stage pipeline (N = %d, blocks = %d, threads/block = %d)...\n",
           N, grid_size, block_size);

    float* d = NULL;
    CHECK_CUDA(cudaMalloc((void**)&d, bytes));
    CHECK_CUDA(cudaMemset(d, 0, bytes));

    // 10 iterations of the 3-stage pipeline
    for (int i = 0; i < 10; ++i) {
        fast_kernel<<<grid_size, block_size>>>(d, N);
        slow_kernel<<<grid_size, block_size>>>(d, N);
        medium_kernel<<<grid_size, block_size>>>(d, N);
    }

    CHECK_CUDA(cudaGetLastError());
    CHECK_CUDA(cudaDeviceSynchronize());

    CHECK_CUDA(cudaFree(d));
    printf("Pipeline completed successfully.\n");

    return 0;
}
