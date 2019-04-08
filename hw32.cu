#include "stdio.h"

#define N 8
#define THREADS 8

__global__ int findLowest(int low, int high, int a[], int *cudaResult ){
    *result = a[low];
    for (int i = low; i < high; i++){
        if(a[i] < lowestNumber){
            lowestNumber = a[i];
        }
    }
    return *result;
}

int main(){
    int *a;
    int low, high, cudaResult, min;
    int *dev_c;

    a = (int *) malloc(sizeof(int)*N);

    for(i = 0; i < N; i++)
            a[i] = rand() % 100000;

    min = a[0];
    
    int numToMinimize = N / THREADS;
    low = rank * numToMinimize;
    high = low + numToMinimize -1;

    cudaMalloc((void**)&dev_c, sizeof(int));
    findLowest<<<1,8>>>(low, high, a, dev_c);
    cudaMemcpy(&cudaResult, dev_c, sizeof(int), cudaMemcpyDeviceToHost )
    if(min > cudaResult){
        min = cudaResult;
    }

    printf("%d \n", min); 
}
