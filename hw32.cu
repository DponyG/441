#include "stdio.h"
#include <limits.h>

#define N 100
#define THREADS 8

__global__ void findLowest(int numToMinimize, int *a, int *cudaResult ){
    
    int low = threadIdx.x * numToMinimize;
    int high = low + numToMinimize -1;
    int min = a[low];
    for (int i = low; i < high; i++){
        if(a[i] < min){
            min = a[i];
        }
    }
    cudaResult[threadIdx.x] = min;
    printf("Thread %d returned: %d \n", threadIdx.x, min);
}

int main(){
    int *a;
    int *cudaResult;
    int min = INT_MAX;
    int testMin = INT_MAX;
    int *dev_result;
    int *dev_a;

    a = (int *) malloc(sizeof(int)*N);
    cudaResult = (int *) malloc(sizeof(int)*N);

    for(unsigned int i = 0; i < N; i++){
        a[i] = rand() % 100000;
        if (testMin > a[i]){
            testMin = a[i];
        } 
    }

    printf("The minimum value is: %d \n", testMin);

    int numToMinimize = N / THREADS;
   
    cudaMalloc((void**)&dev_result, N*sizeof(int));
    cudaMalloc((void**)&dev_a, N*sizeof(int));
    cudaMemcpy(dev_a, a, N*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_result, cudaResult, N*sizeof(int), cudaMemcpyHostToDevice);
    findLowest<<<1,8>>>(numToMinimize, dev_a, dev_result);
    cudaMemcpy(cudaResult, dev_result, N*sizeof(int), cudaMemcpyDeviceToHost);

    for(unsigned int i = 0; i < THREADS; i++){
        if(min > cudaResult[i]) {
            min = cudaResult[i];
        }
    }

    printf("The Cuda Value is %d \n", min); 
}
