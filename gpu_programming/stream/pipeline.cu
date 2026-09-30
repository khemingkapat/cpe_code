#include <cuda_runtime.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NITER 32
#define BLOCK_SIZE 256

// SAXPY variant with tunable compute from Exercise 1
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

void init_vectors(float *a, float *b, int n) {
    for (int i = 0; i < n; ++i) {
        a[i] = 1.0f + 0.001f * (i % 1024);
        b[i] = 2.0f - 0.001f * (i % 512);
    }
}

// Serial baseline (from Exercise 1) using 1 device chunk buffer
float run_serial_baseline(float *h_A, float *h_B, float *h_C,
                          int n_chunks, int n_chunk, float a) {
    float *d_A = NULL, *d_B = NULL, *d_C = NULL;
    cudaMalloc((void **)&d_A, n_chunk * sizeof(float));
    cudaMalloc((void **)&d_B, n_chunk * sizeof(float));
    cudaMalloc((void **)&d_C, n_chunk * sizeof(float));

    dim3 block(BLOCK_SIZE);
    dim3 grid((n_chunk + BLOCK_SIZE - 1) / BLOCK_SIZE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Warm-up pass
    for (int i = 0; i < n_chunks; ++i) {
        int offset = i * n_chunk;
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

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return ms;
}

// Naive Issue Order: all operations of chunk i on stream[s]
void launch_naive(float *h_A, float *h_B, float *h_C,
                  float **d_A, float **d_B, float **d_C,
                  int n_chunks, int n_chunk, int n_streams,
                  float a, cudaStream_t *streams) {
    dim3 block(BLOCK_SIZE);
    dim3 grid((n_chunk + BLOCK_SIZE - 1) / BLOCK_SIZE);

    for (int i = 0; i < n_chunks; ++i) {
        int s = i % n_streams;
        int offset = i * n_chunk;
        cudaMemcpyAsync(d_A[s], h_A + offset, n_chunk * sizeof(float), cudaMemcpyHostToDevice, streams[s]);
        cudaMemcpyAsync(d_B[s], h_B + offset, n_chunk * sizeof(float), cudaMemcpyHostToDevice, streams[s]);
        vec_op<<<grid, block, 0, streams[s]>>>(a, d_A[s], d_B[s], d_C[s], n_chunk);
        cudaMemcpyAsync(h_C + offset, d_C[s], n_chunk * sizeof(float), cudaMemcpyDeviceToHost, streams[s]);
    }
    cudaDeviceSynchronize();
}

// Interleaved Issue Order: phase loop across streams
void launch_interleaved(float *h_A, float *h_B, float *h_C,
                        float **d_A, float **d_B, float **d_C,
                        int n_chunks, int n_chunk, int n_streams,
                        float a, cudaStream_t *streams) {
    dim3 block(BLOCK_SIZE);
    dim3 grid((n_chunk + BLOCK_SIZE - 1) / BLOCK_SIZE);

    for (int base = 0; base < n_chunks; base += n_streams) {
        // Phase 1: All H->D copies of A
        for (int s = 0; s < n_streams; ++s) {
            int i = base + s;
            cudaMemcpyAsync(d_A[s], h_A + i * n_chunk, n_chunk * sizeof(float), cudaMemcpyHostToDevice, streams[s]);
        }
        // Phase 2: All H->D copies of B
        for (int s = 0; s < n_streams; ++s) {
            int i = base + s;
            cudaMemcpyAsync(d_B[s], h_B + i * n_chunk, n_chunk * sizeof(float), cudaMemcpyHostToDevice, streams[s]);
        }
        // Phase 3: All kernel launches
        for (int s = 0; s < n_streams; ++s) {
            vec_op<<<grid, block, 0, streams[s]>>>(a, d_A[s], d_B[s], d_C[s], n_chunk);
        }
        // Phase 4: All D->H copies of C
        for (int s = 0; s < n_streams; ++s) {
            int i = base + s;
            cudaMemcpyAsync(h_C + i * n_chunk, d_C[s], n_chunk * sizeof(float), cudaMemcpyDeviceToHost, streams[s]);
        }
    }
    cudaDeviceSynchronize();
}

// Run a pipeline benchmark configuration
float run_pipeline_benchmark(int is_interleaved, int n_streams,
                             float *h_A, float *h_B, float *h_C, float *h_C_ref,
                             int n_chunks, int n_chunk, float a,
                             bool *out_pass) {
    // Allocate per-stream device buffers
    float *d_A[8], *d_B[8], *d_C[8];
    for (int s = 0; s < n_streams; ++s) {
        cudaMalloc((void **)&d_A[s], n_chunk * sizeof(float));
        cudaMalloc((void **)&d_B[s], n_chunk * sizeof(float));
        cudaMalloc((void **)&d_C[s], n_chunk * sizeof(float));
    }

    // Create streams
    cudaStream_t streams[8];
    for (int s = 0; s < n_streams; ++s) {
        cudaStreamCreate(&streams[s]);
    }

    // Warm-up pass
    if (is_interleaved) {
        launch_interleaved(h_A, h_B, h_C, d_A, d_B, d_C, n_chunks, n_chunk, n_streams, a, streams);
    } else {
        launch_naive(h_A, h_B, h_C, d_A, d_B, d_C, n_chunks, n_chunk, n_streams, a, streams);
    }

    // Clear output buffer before timed measurement
    memset(h_C, 0, (size_t)n_chunks * n_chunk * sizeof(float));

    // Timed trial
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    if (is_interleaved) {
        launch_interleaved(h_A, h_B, h_C, d_A, d_B, d_C, n_chunks, n_chunk, n_streams, a, streams);
    } else {
        launch_naive(h_A, h_B, h_C, d_A, d_B, d_C, n_chunks, n_chunk, n_streams, a, streams);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms = 0.0f;
    cudaEventElapsedTime(&ms, start, stop);

    // Verify bit-exact correctness against reference
    size_t total_bytes = (size_t)n_chunks * n_chunk * sizeof(float);
    *out_pass = (memcmp(h_C, h_C_ref, total_bytes) == 0);

    // Clean up
    for (int s = 0; s < n_streams; ++s) {
        cudaFree(d_A[s]);
        cudaFree(d_B[s]);
        cudaFree(d_C[s]);
        cudaStreamDestroy(streams[s]);
    }
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return ms;
}

int main(int argc, char *argv[]) {
    const int N_CHUNKS = 8;
    const int N_CHUNK = 16 * 1024 * 1024; // 16M elements (64 MB per chunk)
    const int N_TOTAL = N_CHUNKS * N_CHUNK;
    const float a = 2.5f;

    // Device Information
    int deviceId = 0;
    cudaGetDevice(&deviceId);
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, deviceId);

    printf("========================================================================\n");
    printf("Exercise 2: Multi-Stream Pipeline Benchmarking\n");
    printf("GPU Device: %s (Compute Capability %d.%d)\n", prop.name, prop.major, prop.minor);
    printf("Total Elements: %d (128M), Chunks: %d x %d (16M each)\n", N_TOTAL, N_CHUNKS, N_CHUNK);
    printf("========================================================================\n\n");

    // Allocate pinned host memory
    float *h_A = NULL, *h_B = NULL, *h_C = NULL, *h_C_ref = NULL;
    cudaMallocHost((void **)&h_A, (size_t)N_TOTAL * sizeof(float));
    cudaMallocHost((void **)&h_B, (size_t)N_TOTAL * sizeof(float));
    cudaMallocHost((void **)&h_C, (size_t)N_TOTAL * sizeof(float));
    cudaMallocHost((void **)&h_C_ref, (size_t)N_TOTAL * sizeof(float));

    init_vectors(h_A, h_B, N_TOTAL);

    // 1. Establish Serial Pinned Baseline & Reference Output
    printf("Running Serial Pinned Baseline (1 stream)...\n");
    float time_serial = run_serial_baseline(h_A, h_B, h_C_ref, N_CHUNKS, N_CHUNK, a);
    printf("Serial Pinned Baseline Time: %.3f ms\n\n", time_serial);

    // Test Configurations: Naive (2, 4, 8) and Interleaved (2, 4, 8)
    const char *variants[] = {"naive", "naive", "naive", "interleaved", "interleaved", "interleaved"};
    int stream_counts[] = {2, 4, 8, 2, 4, 8};
    int is_interleaved[] = {0, 0, 0, 1, 1, 1};
    float times[6];
    float speedups[6];
    bool passes[6];

    for (int k = 0; k < 6; ++k) {
        printf("Benchmarking %s (N_STREAMS = %d)...\n", variants[k], stream_counts[k]);
        times[k] = run_pipeline_benchmark(
            is_interleaved[k], stream_counts[k],
            h_A, h_B, h_C, h_C_ref,
            N_CHUNKS, N_CHUNK, a, &passes[k]
        );
        speedups[k] = time_serial / times[k];
        printf("  Time: %.3f ms, Speedup: %.3fx, Correctness: %s\n",
               times[k], speedups[k], passes[k] ? "PASS" : "FAIL");
    }

    // Markdown Table matching lab report template
    printf("\n========================================================================\n");
    printf("EXERCISE 2 RESULTS TABLE\n");
    printf("========================================================================\n");
    printf("| variant       | N_STREAMS | time (ms) | speedup vs serial pinned | correctness |\n");
    printf("|:--------------|:----------|:----------|:-------------------------|:------------|\n");
    for (int k = 0; k < 6; ++k) {
        printf("| %-13s | %-9d | %-9.3f | %-24.2f | %-11s |\n",
               variants[k], stream_counts[k], times[k], speedups[k], passes[k] ? "PASS" : "FAIL");
    }
    printf("| %-13s | %-9s | %-9.3f | %-24.2f | %-11s |\n",
           "serial pinned", "—", time_serial, 1.00f, "PASS");
    printf("========================================================================\n");

    // Export pipeline_data.csv for plotting
    const char *csv_filename = "pipeline_data.csv";
    FILE *fp = fopen(csv_filename, "w");
    if (fp) {
        fprintf(fp, "variant,n_streams,time_ms,speedup\n");
        fprintf(fp, "serial,1,%.3f,1.000\n", time_serial);
        for (int k = 0; k < 6; ++k) {
            fprintf(fp, "%s,%d,%.3f,%.3f\n", variants[k], stream_counts[k], times[k], speedups[k]);
        }
        fclose(fp);
        printf("\nSaved benchmark data to '%s'\n", csv_filename);
    }

    // Cleanup
    cudaFreeHost(h_A);
    cudaFreeHost(h_B);
    cudaFreeHost(h_C);
    cudaFreeHost(h_C_ref);

    return 0;
}
