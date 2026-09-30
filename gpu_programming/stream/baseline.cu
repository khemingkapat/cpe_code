#include <cuda_runtime.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define NITER 32
#define BLOCK_SIZE 256

// SAXPY variant with tunable compute as specified in the lab
__global__ void vec_op(float a, const float *x, const float *y, float *z, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        float xi = x[i];
        float yi = y[i];
        float zi = 0.0f;
        for (int k = 0; k < NITER; ++k) {
            zi = a * xi + yi + zi * 0.001f;
            xi = xi * 1.001f + 0.001f; // prevents compile-time elision
        }
        z[i] = zi;
    }
}

// init vectors as mentioned from the docs - just function for shorthands
void init_vectors(float *a, float *b, int n) {
    for (int i = 0; i < n; ++i) {
        a[i] = 1.0f + 0.001f * (i % 1024);
        b[i] = 2.0f - 0.001f * (i % 512);
    }
}

// Run 8 chunks sequentially
float run_serial_benchmark(float *h_A, float *h_B, float *h_C, float *d_A, float *d_B, float *d_C,
                           int n_chunks, int n_chunk, float a, cudaEvent_t start,
                           cudaEvent_t stop) {
    dim3 block(BLOCK_SIZE);
    dim3 grid((n_chunk + BLOCK_SIZE - 1) / BLOCK_SIZE);

    // Warm up first: run the 8 chunks once and cudaDeviceSynchronize before starting the measured
    // trial
    for (int i = 0; i < n_chunks; ++i) {
        int offset = i * n_chunk;
        // ahh pointer indexing - this is what we learned in CPE100
        cudaMemcpy(d_A, h_A + offset, n_chunk * sizeof(float), cudaMemcpyHostToDevice);
        cudaMemcpy(d_B, h_B + offset, n_chunk * sizeof(float), cudaMemcpyHostToDevice);
        vec_op<<<grid, block>>>(a, d_A, d_B, d_C, n_chunk);
        cudaMemcpy(h_C + offset, d_C, n_chunk * sizeof(float), cudaMemcpyDeviceToHost);
    }
    cudaDeviceSynchronize();

    // Measured trial
    cudaEventRecord(start);

    for (int i = 0; i < n_chunks; ++i) {
        int offset = i * n_chunk;
        cudaMemcpy(d_A, h_A + offset, n_chunk * sizeof(float), cudaMemcpyHostToDevice);
        cudaMemcpy(d_B, h_B + offset, n_chunk * sizeof(float), cudaMemcpyHostToDevice);
        vec_op<<<grid, block>>>(a, d_A, d_B, d_C, n_chunk);
        cudaMemcpy(h_C + offset, d_C, n_chunk * sizeof(float), cudaMemcpyDeviceToHost);
    }

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms = 0.0f;
    cudaEventElapsedTime(&ms, start, stop);
    return ms;
}

int main(int argc, char *argv[]) {
    // 8 chunks * 16M elements = 128M elements (512 MB per vector)
    const int N_CHUNKS = 8;
    const int N_CHUNK = 16 * 1024 * 1024; // 16M elements = 64 MB per chunk
    const int N_TOTAL = N_CHUNKS * N_CHUNK;
    const float a = 2.5f;

    // Query and print device information
    int deviceId = 0;
    cudaGetDevice(&deviceId);
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, deviceId);

    printf("============================================================\n");
    printf("GPU Device: %s (Compute Capability %d.%d)\n", prop.name, prop.major, prop.minor);
    printf("PCIe Bus ID: %04x:%02x:%02x\n", prop.pciDomainID, prop.pciBusID, prop.pciDeviceID);
    printf("Total Elements: %d (128M), Chunks: %d x %d (16M each)\n", N_TOTAL, N_CHUNKS, N_CHUNK);
    printf("Memory per vector: %.2f MB, Chunk size: %.2f MB\n",
           (N_TOTAL * sizeof(float)) / (1024.0 * 1024.0),
           (N_CHUNK * sizeof(float)) / (1024.0 * 1024.0));
    printf("============================================================\n\n");

    // Allocate ONE set of device buffers for chunk processing (64 MB each)
    float *d_A = NULL, *d_B = NULL, *d_C = NULL;
    cudaMalloc((void **)&d_A, N_CHUNK * sizeof(float));
    cudaMalloc((void **)&d_B, N_CHUNK * sizeof(float));
    cudaMalloc((void **)&d_C, N_CHUNK * sizeof(float));

    // Create CUDA timing events
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // ============================================================
    // Variant A: Pageable Host Memory (malloc)
    // ============================================================
    printf("--- Variant A: Pageable Host Memory (malloc) ---\n");
    float *h_A_pageable = (float *)malloc(N_TOTAL * sizeof(float));
    float *h_B_pageable = (float *)malloc(N_TOTAL * sizeof(float));
    float *h_C_pageable = (float *)malloc(N_TOTAL * sizeof(float));
    if (!h_A_pageable || !h_B_pageable || !h_C_pageable) {
        fprintf(stderr, "Failed to allocate pageable host memory!\n");
        return 1;
    }

    init_vectors(h_A_pageable, h_B_pageable, N_TOTAL);

    float time_pageable = run_serial_benchmark(h_A_pageable, h_B_pageable, h_C_pageable, d_A, d_B,
                                               d_C, N_CHUNKS, N_CHUNK, a, start, stop);
    printf("Variant A (Pageable) Time: %.3f ms\n", time_pageable);

    printf("Variant A Spot-check (first 10 elements of h_C):\n");
    for (int i = 0; i < 10; ++i) {
        printf("  h_C[%d] = %f\n", i, h_C_pageable[i]);
    }
    printf("\n");

    // ============================================================
    // Variant B: Pinned Host Memory (cudaMallocHost)
    // ============================================================
    printf("--- Variant B: Pinned Host Memory (cudaMallocHost) ---\n");
    float *h_A_pinned = NULL, *h_B_pinned = NULL, *h_C_pinned = NULL;
    cudaMallocHost((void **)&h_A_pinned, N_TOTAL * sizeof(float));
    cudaMallocHost((void **)&h_B_pinned, N_TOTAL * sizeof(float));
    cudaMallocHost((void **)&h_C_pinned, N_TOTAL * sizeof(float));

    init_vectors(h_A_pinned, h_B_pinned, N_TOTAL);

    float time_pinned = run_serial_benchmark(h_A_pinned, h_B_pinned, h_C_pinned, d_A, d_B, d_C,
                                             N_CHUNKS, N_CHUNK, a, start, stop);
    printf("Variant B (Pinned) Time:   %.3f ms\n", time_pinned);

    printf("Variant B Spot-check (first 10 elements of h_C):\n");
    for (int i = 0; i < 10; ++i) {
        printf("  h_C[%d] = %f\n", i, h_C_pinned[i]);
    }
    printf("\n");

    // ============================================================
    // Verification & Analysis
    // ============================================================
    printf("--- Verification & Analysis ---\n");
    bool match = true;
    for (int i = 0; i < N_TOTAL; ++i) {
        if (fabs(h_C_pageable[i] - h_C_pinned[i]) > 1e-4f) {
            match = false;
            printf("Mismatch at index %d: pageable=%f, pinned=%f\n", i, h_C_pageable[i],
                   h_C_pinned[i]);
            break;
        }
    }
    if (match) {
        printf("Verification PASSED: Variant A and Variant B produced identical results!\n");
    } else {
        printf("Verification FAILED: Results differ!\n");
    }

    // Save pinned output as reference for Exercise 2
    const char *ref_filename = "reference_output.bin";
    FILE *fp = fopen(ref_filename, "wb");
    if (fp) {
        size_t written = fwrite(h_C_pinned, sizeof(float), N_TOTAL, fp);
        fclose(fp);
        if (written == (size_t)N_TOTAL) {
            printf("Saved reference output to '%s' for Exercise 2.\n", ref_filename);
        }
    }

    // Performance Metrics
    float speedup = time_pageable / time_pinned;
    // total_bytes_transferred = 8 chunks * 3 vectors * 64 MB = 1536 MB (as defined in lab doc)
    double total_mb_dec = 1536.0;
    double bandwidth_doc = total_mb_dec / (time_pinned / 1000.0); // 1536 MB / total_time_seconds

    printf("\n============================================================\n");
    printf("RESULTS SUMMARY:\n");
    printf("Variant A (Pageable) Time: %.3f ms\n", time_pageable);
    printf("Variant B (Pinned) Time:   %.3f ms\n", time_pinned);
    printf("Pinned Speedup (A/B):      %.2fx\n", speedup);
    printf("Effective Bandwidth (Q3):  %.2f MB/s (%.2f GB/s)\n", bandwidth_doc,
           bandwidth_doc / 1000.0);
    printf("============================================================\n");

    // Cleanup
    free(h_A_pageable);
    free(h_B_pageable);
    free(h_C_pageable);

    cudaFreeHost(h_A_pinned);
    cudaFreeHost(h_B_pinned);
    cudaFreeHost(h_C_pinned);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
