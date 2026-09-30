#include <cuda_runtime.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define N_SMALL 4096
#define N_ITERS 1000
#define BLOCK_SIZE 256

// Kernel 1 (init): fill array with a constant
__global__ void init(float *d, float val, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        d[i] = val;
    }
}

// Kernel 2 (transform): multiply each element by 2
__global__ void transform(float *d, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        d[i] = d[i] * 2.0f;
    }
}

// Kernel 3 (reduce): sum with atomicAdd into a single float
__global__ void reduce(const float *d, float *out, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        atomicAdd(out, d[i]);
    }
}

int main(int argc, char *argv[]) {
    // Device Information
    int deviceId = 0;
    cudaGetDevice(&deviceId);
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, deviceId);

    printf("========================================================================\n");
    printf("Exercise 3: CUDA Graphs on a Repetitive Workload\n");
    printf("GPU Device: %s (Compute Capability %d.%d)\n", prop.name, prop.major, prop.minor);
    printf("Workload: %d iterations of 3 kernels on array size N = %d\n", N_ITERS, N_SMALL);
    printf("Expected final sum: 1.5 * 2.0 * %d = %.1f\n", N_SMALL, 1.5f * 2.0f * (float)N_SMALL);
    printf("========================================================================\n\n");

    // Allocate device buffers
    float *d_data = NULL;
    float *d_sum = NULL;
    cudaMalloc((void **)&d_data, N_SMALL * sizeof(float));
    cudaMalloc((void **)&d_sum, sizeof(float));

    cudaStream_t stream;
    cudaStreamCreate(&stream);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    dim3 block(BLOCK_SIZE);
    dim3 grid((N_SMALL + BLOCK_SIZE - 1) / BLOCK_SIZE);
    const float expected_sum = 1.5f * 2.0f * (float)N_SMALL; // 12288.0f

    // ============================================================
    // Implementation A: Regular Streams (No Graph)
    // ============================================================
    printf("--- Implementation A: Regular Streams ---\n");

    // Warm-up pass (run once)
    cudaMemsetAsync(d_sum, 0, sizeof(float), stream);
    init<<<grid, block, 0, stream>>>(d_data, 1.5f, N_SMALL);
    transform<<<grid, block, 0, stream>>>(d_data, N_SMALL);
    reduce<<<grid, block, 0, stream>>>(d_data, d_sum, N_SMALL);
    cudaStreamSynchronize(stream);

    // Timed trial
    cudaEventRecord(start, stream);
    for (int iter = 0; iter < N_ITERS; ++iter) {
        cudaMemsetAsync(d_sum, 0, sizeof(float), stream);
        init<<<grid, block, 0, stream>>>(d_data, 1.5f, N_SMALL);
        transform<<<grid, block, 0, stream>>>(d_data, N_SMALL);
        reduce<<<grid, block, 0, stream>>>(d_data, d_sum, N_SMALL);
    }
    cudaEventRecord(stop, stream);
    cudaEventSynchronize(stop);

    float time_regular_ms = 0.0f;
    cudaEventElapsedTime(&time_regular_ms, start, stop);

    float h_sum_regular = 0.0f;
    cudaMemcpy(&h_sum_regular, d_sum, sizeof(float), cudaMemcpyDeviceToHost);
    bool pass_regular = (fabs(h_sum_regular - expected_sum) < 1e-2f);

    printf("Regular Streams Total Time: %.3f ms\n", time_regular_ms);
    printf("Regular Streams Per-iteration: %.3f us\n", (time_regular_ms * 1000.0f) / N_ITERS);
    printf("Regular Streams Sum: %.1f (Expected: %.1f) -> %s\n\n",
           h_sum_regular, expected_sum, pass_regular ? "PASS" : "FAIL");

    // ============================================================
    // Implementation B: CUDA Graph via Stream Capture
    // ============================================================
    printf("--- Implementation B: CUDA Graph via Stream Capture ---\n");
    cudaGraph_t graph;
    cudaGraphExec_t graphExec;

    // 1. Warm up: launch once before capture so one-time driver setups do not enter graph
    cudaMemsetAsync(d_sum, 0, sizeof(float), stream);
    init<<<grid, block, 0, stream>>>(d_data, 1.5f, N_SMALL);
    transform<<<grid, block, 0, stream>>>(d_data, N_SMALL);
    reduce<<<grid, block, 0, stream>>>(d_data, d_sum, N_SMALL);
    cudaStreamSynchronize(stream);

    // 2. Capture the sequence into a graph
    cudaStreamBeginCapture(stream, cudaStreamCaptureModeGlobal);
    cudaMemsetAsync(d_sum, 0, sizeof(float), stream);
    init<<<grid, block, 0, stream>>>(d_data, 1.5f, N_SMALL);
    transform<<<grid, block, 0, stream>>>(d_data, N_SMALL);
    reduce<<<grid, block, 0, stream>>>(d_data, d_sum, N_SMALL);
    cudaStreamEndCapture(stream, &graph);

    // 3. Instantiate — one-time optimization and baking
    cudaGraphInstantiate(&graphExec, graph, nullptr, nullptr, 0);

    // 4. Timed trial: Launch the graph 1000 times
    cudaEventRecord(start, stream);
    for (int iter = 0; iter < N_ITERS; ++iter) {
        cudaGraphLaunch(graphExec, stream);
    }
    cudaEventRecord(stop, stream);
    cudaEventSynchronize(stop);

    float time_graph_ms = 0.0f;
    cudaEventElapsedTime(&time_graph_ms, start, stop);

    float h_sum_graph = 0.0f;
    cudaMemcpy(&h_sum_graph, d_sum, sizeof(float), cudaMemcpyDeviceToHost);
    bool pass_graph = (fabs(h_sum_graph - expected_sum) < 1e-2f);

    printf("CUDA Graph Total Time: %.3f ms\n", time_graph_ms);
    printf("CUDA Graph Per-iteration: %.3f us\n", (time_graph_ms * 1000.0f) / N_ITERS);
    printf("CUDA Graph Sum: %.1f (Expected: %.1f) -> %s\n\n",
           h_sum_graph, expected_sum, pass_graph ? "PASS" : "FAIL");

    // Speedup
    float speedup = time_regular_ms / time_graph_ms;

    // ============================================================
    // Results Summary Table
    // ============================================================
    printf("========================================================================\n");
    printf("EXERCISE 3 RESULTS TABLE\n");
    printf("========================================================================\n");
    printf("| variant         | total_time (ms) | time_per_iter (us) | speedup |\n");
    printf("|:----------------|:----------------|:-------------------|:--------|\n");
    printf("| regular streams | %-15.3f | %-18.3f | %-7.2f |\n",
           time_regular_ms, (time_regular_ms * 1000.0f) / N_ITERS, 1.00f);
    printf("| cuda graph      | %-15.3f | %-18.3f | %-7.2f |\n",
           time_graph_ms, (time_graph_ms * 1000.0f) / N_ITERS, speedup);
    printf("========================================================================\n");
    printf("Overall Correctness: %s\n", (pass_regular && pass_graph) ? "PASS" : "FAIL");
    printf("Speedup Ratio: %.2fx faster with CUDA Graphs\n", speedup);
    printf("========================================================================\n");

    // Cleanup
    cudaGraphExecDestroy(graphExec);
    cudaGraphDestroy(graph);

    cudaFree(d_data);
    cudaFree(d_sum);
    cudaStreamDestroy(stream);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
