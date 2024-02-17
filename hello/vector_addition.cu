#include <stdio.h>
#include <stdlib.h>
#define N (1 << 16)
#define N_FLOAT (N*sizeof(float))


// Code written in C 
// void vector_add(float *out, float *a, float *b, int n) {
//     for(int i = 0; i < n; i++){
//         out[i] = a[i] + b[i];
//     }
// }

// int main(){
//     float *a, *b, *out; 

//     // Allocate memory
//     a   = (float*)malloc(sizeof(float) * N);
//     b   = (float*)malloc(sizeof(float) * N);
//     out = (float*)malloc(sizeof(float) * N);

//     // Initialize array
//     for(int i = 0; i < N; i++){
//         a[i] = 1.0f; b[i] = 2.0f;
//     }

//     // Main function
//     vector_add(out, a, b, N);
// }

// ======== We now convert to CUDA code ========

__global__ void vector_add_kernel(float* out, float* a, float* b, int n) {
    for (int i = 0; i < n; i++) {
        out[i] = a[i] + b[i];
    }
}

int main() {
    // allocate memory on CPU
    float* a = (float*)malloc(sizeof(float) * N);
    float* b = (float*)malloc(sizeof(float) * N);
    float* out = (float*)malloc(sizeof(float) * N);

    // init arrays
    for (int i = 0; i < N; i++) {
        a[i] = 1.0f;
        b[i] = 2.0f;
        out[i] = 0;
    }

    // allocate GPU memory
    float *d_a, *d_b, *d_out;
    cudaMalloc(&d_a, N_FLOAT);
    cudaMalloc(&d_b, N_FLOAT);
    cudaMalloc(&d_out, N_FLOAT);

    // Copy the numbers over to device
    cudaMemcpy(d_a, a, N_FLOAT, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, N_FLOAT, cudaMemcpyHostToDevice);
    cudaMemcpy(d_out, out, N_FLOAT, cudaMemcpyHostToDevice);

    // do vector addition
    vector_add_kernel<<<1, 1>>>(d_out, d_a, d_b, N);

    // copy back to host 
    cudaMemcpy(out, d_out, N_FLOAT, cudaMemcpyDeviceToHost);

    printf("Value of C %lf\n", out[0]);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_out);


}