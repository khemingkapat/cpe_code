#include <cuda_runtime.h>
#include <stdio.h>

__global__ void saxpy_compute(float a, const float *x, float *y, int N, int NITER) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        float xi = x[i];
        float yi = y[i];
        for (int k = 0; k < NITER; ++k) {
            yi = a * xi + yi;
            xi = xi * 1.001f + 0.001f; // Prevents compiler optimizing away the loop
        }
        y[i] = yi;
    }
}

int main() {
    int deviceId = 0;
    cudaSetDevice(deviceId);

    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, deviceId);
    int maxThreadsPerSM = prop.maxThreadsPerMultiProcessor;
    int maxWarpsPerSM = maxThreadsPerSM / 32;

    int N = 1 << 24; // 16,777,216 elements
    int NITER = 32;
    float a = 2.0f;
    size_t bytes = (size_t)N * sizeof(float);

    float *h_x = (float *)malloc(bytes);
    float *h_y = (float *)malloc(bytes);

    for (int i = 0; i < N; i++) {
        h_x[i] = 1.0f;
        h_y[i] = 2.0f;
    }

    float *d_x, *d_y;
    cudaMalloc(&d_x, bytes);
    cudaMalloc(&d_y, bytes);

    cudaMemcpy(d_x, h_x, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y, bytes, cudaMemcpyHostToDevice);

    int blockSizes[] = {32, 64, 128, 256, 512, 1024};
    int numSizes = sizeof(blockSizes) / sizeof(blockSizes[0]);

    printf("data = [\n");

    for (int b = 0; b < numSizes; b++) {
        int block = blockSizes[b];
        int grid = (N + block - 1) / block;

        cudaMemcpy(d_y, h_y, bytes, cudaMemcpyHostToDevice);

        saxpy_compute<<<grid, block>>>(a, d_x, d_y, N, NITER);
        cudaDeviceSynchronize();

        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        cudaEventRecord(start);
        for (int trial = 0; trial < 10; ++trial) {
            saxpy_compute<<<grid, block>>>(a, d_x, d_y, N, NITER);
        }
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float ms_total = 0.0f;
        cudaEventElapsedTime(&ms_total, start, stop);
        float ms_per_trial = ms_total / 10.0f;

        cudaEventDestroy(start);
        cudaEventDestroy(stop);

        double transferBytes = 2.0 * (double)N * sizeof(float);
        double bandwidth_GB_s = transferBytes / (ms_per_trial * 1e-3) / 1e9;

        int active_blocks = 0;
        cudaOccupancyMaxActiveBlocksPerMultiprocessor(&active_blocks, saxpy_compute, block,
                                                      0 // dynamic shared memory in bytes
        );

        int active_warps = active_blocks * (block / 32);
        double occupancy_pct = ((double)active_warps / (double)maxWarpsPerSM) * 100.0;

        printf("    [%d, %d, %d, %.2f, %.4f, %.2f]%s\n", block, active_blocks, active_warps,
               occupancy_pct, ms_per_trial, bandwidth_GB_s, (b == numSizes - 1) ? "" : ",");
    }

    printf("]\n");

    cudaFree(d_x);
    cudaFree(d_y);
    free(h_x);
    free(h_y);

    return 0;
}
