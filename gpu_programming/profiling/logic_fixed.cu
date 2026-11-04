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

__global__ void weighted_sum(const float* x, const float* w,
                              float* out, int N)
{
    int gid = blockIdx.x * blockDim.x + threadIdx.x;
    if (gid < N) {
        float sum = 0.0f;
        // Fix: k <= gid ensures element gid is included in sum(x[0..gid] * w[0..gid])
        for (int k = 0; k <= gid; ++k) {
            sum += x[k] * w[k];
        }
        out[gid] = sum;
    }
}

int main() {
    const int N = 32;
    const int block_size = 32;
    const int grid_size = 1;
    size_t bytes = N * sizeof(float);

    float* h_x = (float*)malloc(bytes);
    float* h_w = (float*)malloc(bytes);
    float* h_out = (float*)malloc(bytes);

    for (int i = 0; i < N; ++i) {
        h_x[i] = 1.0f;
        h_w[i] = 1.0f;
    }

    float *d_x = NULL, *d_w = NULL, *d_out = NULL;
    CHECK_CUDA(cudaMalloc((void**)&d_x, bytes));
    CHECK_CUDA(cudaMalloc((void**)&d_w, bytes));
    CHECK_CUDA(cudaMalloc((void**)&d_out, bytes));

    CHECK_CUDA(cudaMemcpy(d_x, h_x, bytes, cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(d_w, h_w, bytes, cudaMemcpyHostToDevice));

    weighted_sum<<<grid_size, block_size>>>(d_x, d_w, d_out, N);
    CHECK_CUDA(cudaGetLastError());
    CHECK_CUDA(cudaDeviceSynchronize());

    CHECK_CUDA(cudaMemcpy(h_out, d_out, bytes, cudaMemcpyDeviceToHost));

    printf("Results (first 10 elements):\n");
    int correct = 1;
    for (int i = 0; i < N; ++i) {
        if (i < 10) {
            printf("  out[%d] = %.1f (expected: %.1f)\n", i, h_out[i], (float)(i + 1));
        }
        if (h_out[i] != (float)(i + 1)) {
            correct = 0;
        }
    }
    printf("Verification: %s\n", correct ? "PASSED" : "FAILED");

    CHECK_CUDA(cudaFree(d_x));
    CHECK_CUDA(cudaFree(d_w));
    CHECK_CUDA(cudaFree(d_out));
    free(h_x);
    free(h_w);
    free(h_out);

    return 0;
}
