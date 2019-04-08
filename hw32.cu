#include "stdio.h"
#include <limits.h>

#define N 8
#define THREADS 8

__global__ void findLowest(int numToMinimize, int *a, int *cudaResult ){
    
    int low = threadIdx.x * numToMinimize;
    int high = low + numToMinimize -1;
    *cudaResult = a[low];
    for (int i = low; i < high; i++){
        if(a[i] < *cudaResult){
            *cudaResult = a[i];
        }
    }
    printf("%d \n", *cudaResult);
}

int main(){
    int *a;
    int min = INT_MAX;
    int testMin = INT_MAX;
    int cudaResult;
    int *dev_result;
    int *dev_a;

    a = (int *) malloc(sizeof(int)*N);

    for(unsigned int i = 0; i < N; i++){
        a[i] = rand() % 100000;
        if (testMin > a[i]){
            testMin = a[i];
        } 
    }

    printf("The minimum value is: %d \n", testMin);

    int numToMinimize = N / THREADS;
   
    cudaMalloc((void**)&dev_result, sizeof(int));
    cudaMalloc((void**)&dev_a, N*sizeof(int));
    cudaMemcpy(dev_a, a, N*sizeof(int), cudaMemcpyHostToDevice);
    findLowest<<<1,8>>>(numToMinimize, dev_a, dev_result);
    cudaMemcpy(&cudaResult, dev_result, sizeof(int), cudaMemcpyDeviceToHost);

    if(min > cudaResult){
        min = cudaResult;
    }

    printf("The Cuda Value is %d \n", min); 
}
