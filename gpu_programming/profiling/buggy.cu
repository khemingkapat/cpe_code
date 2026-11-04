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

__global__ void broken_kernel(float* out, const float* in,
                               int* counter, int N)
{
    __shared__ float scratch[256];
    int tid = threadIdx.x;
    int gid = blockIdx.x * blockDim.x + tid;
    // Bug 1: reads gid even when gid >= N (out-of-bounds read)
    scratch[tid] = in[gid] * 2.0f;
    // Bug 2: __syncthreads in divergent branch (some threads never reach)
    if (tid < 128) {
        __syncthreads();
        scratch[tid] += scratch[tid + 128];
    }
    // Bug 3: race on shared memory (no sync between write and read)
    scratch[tid] = scratch[tid] + 1.0f;
    float v = scratch[(tid + 1) % 256];   // reads neighbor's fresh value — race
    // Bug 4: out-of-bounds write when gid >= N
    atomicAdd(counter, 1);
    out[gid] = v;
}

int main(int argc, char** argv) {
    const int N = 1000;
    const int block_size = 256;
    const int grid_size = (N + block_size - 1) / block_size; // 4 blocks = 1024 threads

    size_t bytes = N * sizeof(float);
    float* h_in = (float*)malloc(bytes);
    float* h_out = (float*)malloc(bytes);
    int h_counter = 0;

    for (int i = 0; i < N; ++i) {
        h_in[i] = (float)(i + 1);
    }

    float *d_in = NULL, *d_out = NULL;
    int *d_counter = NULL;

    CHECK_CUDA(cudaMalloc((void**)&d_in, bytes));
    CHECK_CUDA(cudaMalloc((void**)&d_out, bytes));
    CHECK_CUDA(cudaMalloc((void**)&d_counter, sizeof(int)));

    CHECK_CUDA(cudaMemcpy(d_in, h_in, bytes, cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(d_counter, &h_counter, sizeof(int), cudaMemcpyHostToDevice));

    broken_kernel<<<grid_size, block_size>>>(d_out, d_in, d_counter, N);
    cudaError_t sync_err = cudaDeviceSynchronize();
    if (sync_err != cudaSuccess) {
        fprintf(stderr, "Kernel execution error: %s\n", cudaGetErrorString(sync_err));
    }

    CHECK_CUDA(cudaMemcpy(h_out, d_out, bytes, cudaMemcpyDeviceToHost));
    CHECK_CUDA(cudaMemcpy(&h_counter, d_counter, sizeof(int), cudaMemcpyDeviceToHost));

    printf("out[0] = %f, counter = %d\n", h_out[0], h_counter);

    CHECK_CUDA(cudaFree(d_in));
    CHECK_CUDA(cudaFree(d_out));
    CHECK_CUDA(cudaFree(d_counter));
    free(h_in);
    free(h_out);

    return 0;
}
