#include <cuda_runtime.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define THRESHOLD 16

__device__ float heavy_compute(int x) {
    float f = (float)x;
    for (int k = 0; k < 1000; ++k) {
        f = f * 1.0001f + 0.001f;
    }
    return f;
}

__device__ float light_compute(int x) {
    float f = (float)x;
    for (int k = 0; k < 100; ++k) {
        f = f * 1.0001f + 0.001f;
    }
    return f;
}

__global__ void branch_kernel(const int *input, float *output, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        output[i] = (input[i] < THRESHOLD) ? heavy_compute(input[i]) : light_compute(input[i]);
    }
}

float cpu_heavy_compute(int x) {
    float f = (float)x;
    for (int k = 0; k < 1000; ++k) {
        f = f * 1.0001f + 0.001f;
    }
    return f;
}

float cpu_light_compute(int x) {
    float f = (float)x;
    for (int k = 0; k < 100; ++k) {
        f = f * 1.0001f + 0.001f;
    }
    return f;
}

void cpu_branch_kernel(const int *input, float *output, int N) {
    for (int i = 0; i < N; ++i) {
        output[i] =
            (input[i] < THRESHOLD) ? cpu_heavy_compute(input[i]) : cpu_light_compute(input[i]);
    }
}

// Warm-up launch + 10 timed trials; return avg time in ms
float benchmark_kernel(const int *d_input, float *d_output, int N, int grid, int block) {
    branch_kernel<<<grid, block>>>(d_input, d_output, N);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int trial = 0; trial < 10; ++trial) {
        branch_kernel<<<grid, block>>>(d_input, d_output, N);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float total_ms = 0.0f;
    cudaEventElapsedTime(&total_ms, start, stop);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return total_ms / 10.0f;
}

int main() {
    int N = 1 << 24; // 16,777,216 elements
    size_t bytes_int = (size_t)N * sizeof(int);
    size_t bytes_float = (size_t)N * sizeof(float);

    int block = 256;
    int grid = (N + block - 1) / block;

    // Host buffers
    int *h_input_A = (int *)malloc(bytes_int);
    int *h_input_B = (int *)malloc(bytes_int);
    int *h_input_C = (int *)malloc(bytes_int);

    float *h_out_ref = (float *)malloc(bytes_float);
    float *h_out_test = (float *)malloc(bytes_float);

    srand(42);

    // Input patterns
    for (int i = 0; i < N; ++i) {
        h_input_A[i] = i % 32;        // Variant A: intra-warp divergence
        h_input_B[i] = (i / 32) % 32; // Variant B: warp-aligned branching
        h_input_C[i] = rand() % 32;   // Variant C: random divergence
    }

    int *d_input;
    float *d_output;
    cudaMalloc(&d_input, bytes_int);
    cudaMalloc(&d_output, bytes_float);

    const char *names[] = {"Variant A (Intra-warp)", "Variant B (Warp-aligned)",
                           "Variant C (Random)"};
    int *inputs[] = {h_input_A, h_input_B, h_input_C};

    printf("=== Timing + verification (each variant on its own input pattern) ===\n");
    printf("| Variant                   | Time (ms) | Throughput (M elements/s) |\n");
    printf("|---------------------------|-----------|---------------------------|\n");

    float times[3];
    for (int v = 0; v < 3; ++v) {
        cudaMemcpy(d_input, inputs[v], bytes_int, cudaMemcpyHostToDevice);
        times[v] = benchmark_kernel(d_input, d_output, N, grid, block);
        double throughput = ((double)N / (times[v] * 1e-3)) / 1e6;

        printf("| %-25s | %9.4f | %25.2f |           ", names[v], times[v], throughput);

        // Fetch this variant's GPU output
        cudaMemcpy(h_out_test, d_output, bytes_float, cudaMemcpyDeviceToHost);

        // Compute the CPU serial reference for THIS variant's own input
        cpu_branch_kernel(inputs[v], h_out_ref, N);

        bool correct = true;
        for (int i = 0; i < N; ++i) {
            if (fabs(h_out_ref[i] - h_out_test[i]) > 1e-1f) {
                printf("incorrect at %d : (ref -> %.5f, test -> %.5f)", i, h_out_ref[i],
                       h_out_test[i]);
                correct = false;
                break;
            }
        }
        printf("  %-24s vs CPU ref: %s\n", names[v], correct ? "PASSED" : "FAILED");
    }

    printf("\nDivergence penalty (Time A / Time B): %.2fx\n", times[0] / times[1]);
    printf("Divergence penalty (Time C / Time B): %.2fx\n", times[2] / times[1]);

    // Cleanup
    cudaFree(d_input);
    cudaFree(d_output);
    free(h_input_A);
    free(h_input_B);
    free(h_input_C);
    free(h_out_ref);
    free(h_out_test);

    return 0;
}
