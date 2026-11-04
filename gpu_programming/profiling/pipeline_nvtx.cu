#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <nvtx3/nvToolsExt.h>

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

    nvtxRangePushA("Setup");
    printf("Initializing pipeline with NVTX annotations (N = %d)...\n", N);
    float* d = NULL;
    CHECK_CUDA(cudaMalloc((void**)&d, bytes));
    CHECK_CUDA(cudaMemset(d, 0, bytes));
    nvtxRangePop();

    // 10 iterations of the 3-stage pipeline with NVTX ranges
    for (int i = 0; i < 10; ++i) {
        nvtxRangePushA("Iteration");

        nvtxRangePushA("Fast phase");
        fast_kernel<<<grid_size, block_size>>>(d, N);
        nvtxRangePop();

        nvtxRangePushA("Slow phase");
        slow_kernel<<<grid_size, block_size>>>(d, N);
        nvtxRangePop();

        nvtxRangePushA("Medium phase");
        medium_kernel<<<grid_size, block_size>>>(d, N);
        nvtxRangePop();

        nvtxRangePop(); // Iteration
    }

    CHECK_CUDA(cudaGetLastError());
    CHECK_CUDA(cudaDeviceSynchronize());

    nvtxRangePushA("Cleanup");
    CHECK_CUDA(cudaFree(d));
    nvtxRangePop();

    printf("Pipeline with NVTX completed successfully.\n");
    return 0;
}
