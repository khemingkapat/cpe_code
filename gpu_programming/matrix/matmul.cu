#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>


__global__ void matMulKernel(const float *A, const float *B,float *C, int N){
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if (row < N && col < N) {
	float sum = 0.0f;
	for (int k = 0; k < N; k++) {
	    sum += A[row * N + k]* B[k * N + col];
	}
	C[row * N + col] = sum;
    }
}

int main(int argc, char *argv[]) {
    int N;
    if (argc > 1) {
        N = atoi(argv[1]); // Convert string argument to integer
    } else {
        printf("No dimension provided. Using default N = %d\n", N);
        printf("Usage: %s <matrix_size_N>\n", argv[0]);
    }
    float offset = N*N;
    size_t size = N * N * sizeof(float);
    

    float *h_A = (float *)malloc(size);
    float *h_B = (float *)malloc(size);
    float *h_C = (float *)malloc(size);

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            int index = i * N + j;
            h_A[index] = (float)(index + 1);
	    h_B[index] = h_A[index] + offset;
        }
    }

    float *d_A;
    float *d_B;
    float *d_C;

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
    dim3 block(16, 16);
    dim3 grid((N + block.x - 1) / block.x,
	    (N + block.y - 1) / block.y);
    matMulKernel<<<grid, block>>>(d_A, d_B, d_C, N);

    err = cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess) {
        printf("cudaMemcpy Device to Host for h_C failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    for(int row = 0;row < N;row ++){
	for(int col = 0;col<N;col++){
	    float expected = 0.0f;
	    for (int k = 0; k < N; k++) {
		expected += h_A[row * N + k]* h_B[k * N + col];
	    }
	    float result = h_C[row*N + col];
	    printf("result in h_C[%d,%d] = %.1f",row,col,result);
	    if(expected != h_C[row * N + col]){
		printf("error : expected = %.1f,h_C = %1.f\n",expected,result);
	    }
	}
    }

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

    free(h_A);
    free(h_B);

    return 0;

}
