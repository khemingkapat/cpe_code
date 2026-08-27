#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

#define BLUR_SIZE 2

__global__ void greyKernel(const unsigned char *rgb, unsigned char *gray, int width, int height) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    if (row < height && col < width) {
        int i = (row * width + col) * 3;
        unsigned char r = rgb[i];
        unsigned char g = rgb[i + 1];
        unsigned char b = rgb[i + 2];
        gray[row * width + col] = (unsigned char)(0.21f * r + 0.71f * g + 0.07f * b);
    }
}

__global__ void blurKernel(const unsigned char *in, unsigned char *out, int width, int height) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    int sum = 0, count = 0;
    for (int dy = -BLUR_SIZE; dy <= BLUR_SIZE; dy++) {
        for (int dx = -BLUR_SIZE; dx <= BLUR_SIZE; dx++) {
            int r = row + dy, c = col + dx;
            if (r >= 0 && r < height && c >= 0 && c < width) {
                sum += in[r * width + c];
                count++;
            }
        }
    }
    out[row * width + col] = (unsigned char)(sum / count);
}

void makeImage(unsigned char *rgb, int width, int height) {
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            int i = (row * width + col) * 3;
            rgb[i + 0] = (unsigned char)((col * 255) / width);
            rgb[i + 1] = (unsigned char)((row * 255) / height);
            rgb[i + 2] = (((row / 32) + (col / 32)) % 2) ? 220 : 40;
        }
    }
}

void cpuGray(const unsigned char *rgb, unsigned char *gray, int width, int height) {
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            int g0 = row * width + col;
            int r0 = g0 * 3;
            gray[g0] =
                (unsigned char)(0.21f * rgb[r0 + 0] + 0.71f * rgb[r0 + 1] + 0.07f * rgb[r0 + 2]);
        }
    }
}

void cpuBlur(const unsigned char *in, unsigned char *out, int width, int height) {
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            int sum = 0, count = 0;
            for (int dy = -BLUR_SIZE; dy <= BLUR_SIZE; dy++) {
                for (int dx = -BLUR_SIZE; dx <= BLUR_SIZE; dx++) {
                    int r = row + dy, c = col + dx;
                    if (r >= 0 && r < height && c >= 0 && c < width) {
                        sum += in[r * width + c];
                        count++;
                    }
                }
            }
            out[row * width + col] = (unsigned char)(sum / count);
        }
    }
}

int compare(const char *label, const unsigned char *got, const unsigned char *want, int n,
            int tol) {
    int bad = 0;
    for (int i = 0; i < n; i++) {
        int d = (int)got[i] - (int)want[i];
        if (d < 0)
            d = -d;
        if (d > tol) {
            if (bad < 5) {
                printf(" %s mismatch at i=%d: got %d, expected %d\n", label, i, (int)got[i],
                       (int)want[i]);
            }
            bad++;
        }
    }
    if (bad == 0)
        printf("%s PASS\n", label);
    else
        printf("%s FAIL: %d of %d pixels wrong\n", label, bad, n);
    return bad;
}

float timeBlur(const unsigned char *d_in, unsigned char *d_out, int width, int height, int bx,
               int by) {
    dim3 block(bx, by);
    dim3 grid((width + bx - 1) / bx, (height + by - 1) / by);
    blurKernel<<<grid, block>>>(d_in, d_out, width, height);
    cudaDeviceSynchronize();
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    for (int i = 0; i < 10; i++) {
        blurKernel<<<grid, block>>>(d_in, d_out, width, height);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms = 0.0f;
    cudaEventElapsedTime(&ms, start, stop);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    return ms / 10.0f;
}

int main(int argc, char *argv[]) {
    int N = 512;
    if (argc > 1) {
        N = atoi(argv[1]); // Convert string argument to integer
    } else {
        printf("No dimension provided. Using default N = %d\n", N);
        printf("Usage: %s <matrix_size_N>\n", argv[0]);
    }
    size_t size_in = N * N * 3 * sizeof(unsigned char);
    size_t size_out = N * N * sizeof(unsigned char);
    unsigned char *h_In = (unsigned char *)malloc(size_in);
    unsigned char *h_Out = (unsigned char *)malloc(size_out);
    unsigned char *h_cpu_result = (unsigned char *)malloc(size_out);
    unsigned char *h_Blur = (unsigned char *)malloc(size_out);
    unsigned char *h_cpu_blur = (unsigned char *)malloc(size_out);

    makeImage(h_In, N, N);
    cpuGray(h_In, h_cpu_result, N, N);

    unsigned char *d_In;
    unsigned char *d_Grey;
    unsigned char *d_Blur;

    cudaError_t err;

    err = cudaMalloc((void **)&d_In, size_in);
    if (err != cudaSuccess) {
        printf("cudaMalloc d_In failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaMalloc((void **)&d_Grey, size_out);
    if (err != cudaSuccess) {
        printf("cudaMalloc d_Grey failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaMalloc((void **)&d_Blur, size_out);
    if (err != cudaSuccess) {
        printf("cudaMalloc d_Blur failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaMemcpy(d_In, h_In, size_in, cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        printf("cudaMemcpy Host to Device for d_In failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    dim3 block(16, 16);
    dim3 grid((N + block.x - 1) / block.x, (N + block.y - 1) / block.y);
    greyKernel<<<grid, block>>>(d_In, d_Grey, N, N);

    err = cudaMemcpy(h_Out, d_Grey, size_out, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess) {
        printf("cudaMemcpy Device to Host for h_Out failed: %s\n", cudaGetErrorString(err));
        return 1;
    }
    compare("Grayscale Test", h_Out, h_cpu_result, N * N, 1);

    // Compute CPU Blur reference for checking
    cpuBlur(h_Out, h_cpu_blur, N, N);

    float t1 = timeBlur(d_Grey, d_Blur, N, N, 8, 8);
    cudaMemcpy(h_Blur, d_Blur, size_out, cudaMemcpyDeviceToHost);
    compare("Blur 8x8", h_Blur, h_cpu_blur, N * N, 1);
    printf("Block 8x8   (64 threads):  %f ms\n\n", t1);

    float t2 = timeBlur(d_Grey, d_Blur, N, N, 16, 16);
    cudaMemcpy(h_Blur, d_Blur, size_out, cudaMemcpyDeviceToHost);
    compare("Blur 16x16", h_Blur, h_cpu_blur, N * N, 1);
    printf("Block 16x16 (256 threads): %f ms\n\n", t2);

    float t3 = timeBlur(d_Grey, d_Blur, N, N, 32, 8);
    cudaMemcpy(h_Blur, d_Blur, size_out, cudaMemcpyDeviceToHost);
    compare("Blur 32x8", h_Blur, h_cpu_blur, N * N, 1);
    printf("Block 32x8  (256 threads): %f ms\n\n", t3);

    float t4 = timeBlur(d_Grey, d_Blur, N, N, 8, 32);
    cudaMemcpy(h_Blur, d_Blur, size_out, cudaMemcpyDeviceToHost);
    compare("Blur 8x32", h_Blur, h_cpu_blur, N * N, 1);
    printf("Block 8x32  (256 threads): %f ms\n\n", t4);

    err = cudaFree(d_In);
    if (err != cudaSuccess) {
        printf("cudaFree d_In failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaFree(d_Grey);
    if (err != cudaSuccess) {
        printf("cudaFree d_Grey failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaFree(d_Blur);
    if (err != cudaSuccess) {
        printf("cudaFree d_Blur failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    free(h_In);
    free(h_Out);
    free(h_cpu_result);
    free(h_Blur);
    free(h_cpu_blur);

    return 0;
}
/* ========== Lab Result ==============

Grayscale Test PASS
Blur 8x8 PASS
Block 8x8   (64 threads):  4.917005 ms

Blur 16x16 PASS
Block 16x16 (256 threads): 2.482583 ms

Blur 32x8 PASS
Block 32x8  (256 threads): 1.649328 ms

Blur 8x32 PASS
Block 8x32  (256 threads): 4.536410 ms

>> note that I use this on the Colab GPU because at the time I am running it queue is full so I
think colab is the way to go
*/

/*
discussions :
1. Given above in the Lab Result : fastest with 32x8 and slowest in the 8x8
2. I did some research and found it about "warp", which is like amount of thread that forced on each
block to read memory at the same time. the xdim=32 one will read 32 "contiguous" memory so it is
faster but for xdim=8 it would read 4 "non-contiguous" memory so it is slower. It is not exactly
about speed of calculation, but the memory access
3. it is just slower, it have smaller thread per block and size of 8 so like 8x32
4. I tested it on blur, it doesn't really have anything because it just did some calculation on the
non-existing column and so no error from mismatch with cpu
5. from width and height using same calculation. the ceil(1000/16) = 63 ; which really resulting in
16*63 = 1008 threads in both col and row. so only 8 thread in last block of row and col doesn't have
anything to do
 */
