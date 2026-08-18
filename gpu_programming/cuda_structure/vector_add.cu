#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <math.h>

// GPU kernel
__global__ void vecAdd3(const float *d_A,
                        const float *d_B,
                        const float *d_C,
                        float *d_D,
                        int n)
{
    // Calculate the global thread index
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    // Boundary check
    if (i < n) {
        d_D[i] = d_A[i] + d_B[i] + d_C[i];
    }
}

int main()
{
    const int n = 100000;
    size_t size = n * sizeof(float);

    // -----------------------------
    // 1. Allocate HOST memory
    // -----------------------------
    float *h_A = (float *)malloc(size);
    float *h_B = (float *)malloc(size);
    float *h_C = (float *)malloc(size);
    float *h_D = (float *)malloc(size);

    // Initialize input vectors
    for (int i = 0; i < n; i++) {
        h_A[i] = (float)i;
        h_B[i] = (float)(2 * i);
        h_C[i] = (float)(3 * i);
    }

    // -----------------------------
    // 2. Allocate DEVICE memory
    // -----------------------------
    float *d_A;
    float *d_B;
    float *d_C;
    float *d_D;

    cudaError_t err;

    err = cudaMalloc((void **)&d_A, size);
    if (err != cudaSuccess) {
        printf("cudaMalloc d_A failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaMalloc((void **)&d_B, size);
    if (err != cudaSuccess) {
        printf("cudaMalloc d_B failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaMalloc((void **)&d_C, size);
    if (err != cudaSuccess) {
        printf("cudaMalloc d_C failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaMalloc((void **)&d_D, size);
    if (err != cudaSuccess) {
       printf("cudaMalloc d_D failed: %s\n", cudaGetErrorString(err));
       return 1;
    }

    // -----------------------------
    // 3. Copy HOST -> DEVICE
    // -----------------------------
    err = cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        printf("cudaMemcpy Host to Device for d_A failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        printf("cudaMemcpy Host to Device for d_B failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaMemcpy(d_C, h_C, size, cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        printf("cudaMemcpy Host to Device for d_C failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    // -----------------------------
    // 4. Configure GPU execution
    // -----------------------------
    int blockSize = 256;
    int gridSize = (n + blockSize - 1) / blockSize;

    printf("Vector size       : %d\n", n);
    printf("Threads per block : %d\n", blockSize);
    printf("Number of blocks  : %d\n", gridSize);
    printf("Total GPU threads : %d\n\n", gridSize * blockSize);

    // -----------------------------
    // 5. Launch GPU kernel
    // -----------------------------
    vecAdd3<<<gridSize, blockSize>>>(d_A, d_B, d_C, d_D, n);

    // Check kernel launch
    err = cudaGetLastError();
    if (err != cudaSuccess) {
        printf("Kernel launch error: %s\n", cudaGetErrorString(err));
        return 1;
    }

    // Wait until GPU computation finishes
    err = cudaDeviceSynchronize();
    if (err != cudaSuccess) {
        printf("cudaDeviceSynchronize failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    // -----------------------------
    // 6. Copy DEVICE -> HOST
    // -----------------------------
    err = cudaMemcpy(h_D, d_D, size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess) {
        printf("cudaMemcpy Device to Host for h_D failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    // -----------------------------
    // 7. Check results
    // -----------------------------
    int mismatches = 0;
    int mismatch_limit = 20;
    bool correct = true;

    for (int i = 0; i < n; i++) {
        float expected = h_A[i] + h_B[i] + h_C[i];

        if (fabsf(h_D[i] - expected) > 1e-5) {
            correct=false;
            if (mismatches++ < mismatch_limit) {
                printf("error at %d : expected %.1f actual %.1f\n", i, expected, h_D[i]);
            }
        }
    }

    if (correct) {
        printf("All %d element addition in 3 vectors are correct!\n", n);
    }
    printf("with total of %d / %d error(s)!\n\n", mismatches, n);

    // Print first 10 results
    printf("First 10 results:\n");

    for (int i = 0; i < 10; i++) {
        printf(
            "Thread %d: %.1f + %.1f + %.1f = %.1f\n",
            i,
            h_A[i],
            h_B[i],
            h_C[i],
            h_D[i]
        );
    }

    // -----------------------------
    // 8. Free DEVICE memory
    // -----------------------------
    err = cudaFree(d_A);
    if (err != cudaSuccess) {
        printf("cudaFree d_A failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaFree(d_B);
    if (err != cudaSuccess) {
        printf("cudaFree d_B failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaFree(d_C);
    if (err != cudaSuccess) {
        printf("cudaFree d_C failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaFree(d_D);
    if (err != cudaSuccess) {
        printf("cudaFree d_D failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    // -----------------------------
    // 9. Free HOST memory
    // -----------------------------
    free(h_A);
    free(h_B);
    free(h_C);
    free(h_D);

    return 0;
}
