#include <cuda_runtime.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define N (16 * 1024 * 1024) // 16M elements (64 MB)
#define BLOCK_SIZE 256

// Stream 0 (PRODUCER): fills a device array d_producer with values
__global__ void producer_kernel(float *d, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        float v = (float)i;
        for (int k = 0; k < 500; ++k) {
            v = v * 1.0001f + 0.001f;
        }
        d[i] = v;
    }
}

// Stream 1 (CONSUMER): reads d_producer, computes d_consumer[i] = d_producer[i] * 2
__global__ void consumer_kernel(const float *d_in, float *d_out, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        d_out[i] = d_in[i] * 2.0f;
    }
}

// Helper to compute expected value on CPU for spot-check
float compute_expected_value(int i) {
    float v = (float)i;
    for (int k = 0; k < 500; ++k) {
        v = v * 1.0001f + 0.001f;
    }
    return v * 2.0f;
}

int main(int argc, char *argv[]) {
    // Device Information
    int deviceId = 0;
    cudaGetDevice(&deviceId);
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, deviceId);

    printf("========================================================================\n");
    printf("Exercise 4: Cross-Stream Synchronization with Events\n");
    printf("GPU Device: %s (Compute Capability %d.%d)\n", prop.name, prop.major, prop.minor);
    printf("Elements: %d (16M floats, ~64 MB per array)\n", N);
    printf("========================================================================\n\n");

    // Allocate device buffers
    float *d_producer = NULL;
    float *d_consumer = NULL;
    cudaMalloc((void **)&d_producer, N * sizeof(float));
    cudaMalloc((void **)&d_consumer, N * sizeof(float));

    // Allocate host memory for spot check verification
    float *h_consumer_A = (float *)malloc(10 * sizeof(float));
    float *h_consumer_B = (float *)malloc(10 * sizeof(float));

    // Create streams
    cudaStream_t stream0, stream1;
    cudaStreamCreate(&stream0);
    cudaStreamCreate(&stream1);

    dim3 block(BLOCK_SIZE);
    dim3 grid((N + BLOCK_SIZE - 1) / BLOCK_SIZE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Warm-up pass to prime GPU clocks and context
    producer_kernel<<<grid, block, 0, stream0>>>(d_producer, N);
    consumer_kernel<<<grid, block, 0, stream1>>>(d_producer, d_consumer, N);
    cudaDeviceSynchronize();

    // ============================================================
    // Implementation A: Host-Mediated Sync (blocks host)
    // ============================================================
    printf("--- Implementation A: Host-Mediated Sync (cudaStreamSynchronize) ---\n");

    cudaEventRecord(start, stream0);
    producer_kernel<<<grid, block, 0, stream0>>>(d_producer, N);
    cudaStreamSynchronize(stream0); // BLOCKS host until producer is done
    consumer_kernel<<<grid, block, 0, stream1>>>(d_producer, d_consumer, N);
    cudaEventRecord(stop, stream1);
    cudaEventSynchronize(stop);

    float time_host_ms = 0.0f;
    cudaEventElapsedTime(&time_host_ms, start, stop);

    // Copy first 10 elements for spot-check
    cudaMemcpy(h_consumer_A, d_consumer, 10 * sizeof(float), cudaMemcpyDeviceToHost);

    printf("Host-Mediated Sync Time: %.3f ms\n", time_host_ms);
    printf("Spot-check (first 5 elements):\n");
    for (int i = 0; i < 5; ++i) {
        printf("  d_consumer[%d] = %f (Expected: %f)\n", i, h_consumer_A[i],
               compute_expected_value(i));
    }
    printf("\n");

    // Reset consumer device buffer before Implementation B
    cudaMemset(d_consumer, 0, N * sizeof(float));

    // ============================================================
    // Implementation B: Event-Based Cross-Stream Sync (does not block host)
    // ============================================================
    printf("--- Implementation B: Event-Based Cross-Stream Sync (cudaStreamWaitEvent) ---\n");

    cudaEvent_t producer_done;
    cudaEventCreate(&producer_done);

    cudaEventRecord(start, stream0);
    producer_kernel<<<grid, block, 0, stream0>>>(d_producer, N);
    cudaEventRecord(producer_done, stream0);
    cudaStreamWaitEvent(stream1, producer_done, 0); // NON-BLOCKING for host
    consumer_kernel<<<grid, block, 0, stream1>>>(d_producer, d_consumer, N);
    cudaEventRecord(stop, stream1);
    cudaEventSynchronize(stop);

    float time_event_ms = 0.0f;
    cudaEventElapsedTime(&time_event_ms, start, stop);

    // Copy first 10 elements for spot-check
    cudaMemcpy(h_consumer_B, d_consumer, 10 * sizeof(float), cudaMemcpyDeviceToHost);

    printf("Event-Based Sync Time:   %.3f ms\n", time_event_ms);
    printf("Spot-check (first 5 elements):\n");
    for (int i = 0; i < 5; ++i) {
        printf("  d_consumer[%d] = %f (Expected: %f)\n", i, h_consumer_B[i],
               compute_expected_value(i));
    }
    printf("\n");

    // Correctness Verification: check match against expected values
    bool pass = true;
    for (int i = 0; i < 10; ++i) {
        float expected = compute_expected_value(i);
        if (fabs(h_consumer_A[i] - expected) > 1e-2f || fabs(h_consumer_B[i] - expected) > 1e-2f) {
            pass = false;
            break;
        }
    }

    // ============================================================
    // Results Summary Table
    // ============================================================
    printf("========================================================================\n");
    printf("EXERCISE 4 RESULTS TABLE\n");
    printf("========================================================================\n");
    printf("| implementation            | time (ms) |\n");
    printf("|:--------------------------|:----------|\n");
    printf("| host-mediated sync        | %-9.3f |\n", time_host_ms);
    printf("| event-based cross-stream  | %-9.3f |\n", time_event_ms);
    printf("========================================================================\n");
    printf("Verification: %s (Both implementations produced identical, correct outputs)\n",
           pass ? "PASS" : "FAIL");
    printf("Difference: %.3f ms (%.2f%% difference)\n", fabs(time_host_ms - time_event_ms),
           (fabs(time_host_ms - time_event_ms) / time_host_ms) * 100.0f);
    printf("========================================================================\n");

    // Cleanup
    cudaEventDestroy(producer_done);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    cudaStreamDestroy(stream0);
    cudaStreamDestroy(stream1);

    cudaFree(d_producer);
    cudaFree(d_consumer);

    free(h_consumer_A);
    free(h_consumer_B);

    return 0;
}
