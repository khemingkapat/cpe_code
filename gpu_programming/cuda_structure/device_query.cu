#include <stdio.h>

int main() {
    int count;
    cudaGetDeviceCount(&count);
    printf("Devices supporting CUDA: %d\n\n", count);

    for (int i = 0; i < count; i++) {
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop, i);

        printf("Device %d: \"%s\"\n", i, prop.name);
        printf("  Compute capability:            %d.%d\n", prop.major, prop.minor);
        printf("  Multiprocessors (SMs):         %d\n", prop.multiProcessorCount);
        printf("  Max threads per SM:            %d\n", prop.maxThreadsPerMultiProcessor);
        printf("  Max threads per block:         %d\n", prop.maxThreadsPerBlock);

        // Derived: max warps per SM
        int maxWarpsPerSM = prop.maxThreadsPerMultiProcessor / prop.warpSize;
        printf("  Max warps per SM:              %d\n", maxWarpsPerSM);

        printf("  Max blocks per SM:             %d\n", prop.maxBlocksPerMultiProcessor);
        printf("  Warp size:                     %d\n", prop.warpSize);
        printf("  Registers per SM:              %d\n", prop.regsPerMultiprocessor);
        printf("  Registers per block:           %d\n", prop.regsPerBlock);
        printf("  Shared memory per SM:          %zu bytes\n", prop.sharedMemPerMultiprocessor);
        printf("  Shared memory per block:       %zu bytes\n", prop.sharedMemPerBlock);
        printf("  L2 cache size:                 %d bytes\n", prop.l2CacheSize);
        printf("  Global memory total:           %.2f GB\n", prop.totalGlobalMem / 1073741824.0);
        printf("  Memory clock rate:             %d kHz\n", prop.memoryClockRate);
        printf("  Memory bus width:              %d bits\n", prop.memoryBusWidth);

        // Derived: Peak memory bandwidth
        // Formula: 2 * clockRate * busWidth / 8
        // Since memoryClockRate is in kHz, we divide by 1e6 to convert to GB/s
        double peakBandwidth = (2.0 * prop.memoryClockRate * prop.memoryBusWidth) / (8.0 * 1e6);
        printf("  Peak memory bandwidth:         %.2f GB/s\n", peakBandwidth);

        printf("\n");
    }
    return 0;
}
