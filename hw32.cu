#include "stdio.h"
#include <limits.h>

#define N 8
#define THREADS 8

__global__ void findLowest(int low, int high, int a[], int *cudaResult ){
    *cudaResult = a[low];
    for (int i = low; i < high; i++){
        if(a[i] < *cudaResult){
            *cudaResult = a[i];
        }
    }
}

int main(){
    int *a;
    int min = INT_MAX;
    int low, high, cudaResult;
    int *dev_c;

    a = (int *) malloc(sizeof(int)*N);

    for(unsigned int i = 0; i < N; i++)
            a[i] = rand() % 100000;

    min = a[0];
    
    int numToMinimize = N / THREADS;
    low = threadIdx.x * numToMinimize;
    high = low + numToMinimize -1;

    cudaMalloc((void**)&dev_c, sizeof(int));
    findLowest<<<1,8>>>(low, high, a, dev_c);
    cudaMemcpy(&cudaResult, dev_c, sizeof(int), cudaMemcpyDeviceToHost);
    if(min > cudaResult){
        min = cudaResult;
    }

    printf("%d \n", min); 
}
