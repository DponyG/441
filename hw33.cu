
#include "stdio.h"
#define COLUMNS 4
#define ROWS 3

__global__ void add(int * a, int*b)  {

    int x = threadIdx.x;
    int sum = 0;

    for(unsigned int i = 0; i < ROWS; i++){
        sum += a[i*COLUMNS+x];
    }

    b[x] = sum;
    
}

int main() {
    int a[ROWS][COLUMNS], n[ROWS][COLUMNS], c[ROWS][COLUMNS];
    int *dev_a, *dev_b; 

    cudaMalloc((void **) &dev_a, ROWS*COLUMNS*sizeof(int));
    cudaMalloc((void **) &dev_b, COLUMNS*sizeof(int));


    for (int y = 0; y< ROWS; y++)
        for(int x = 0; x < COLUMNS; x++){
            a[y][x] = x;
            b[y][x] = y;
        }
    
    cudaMemcpy(dev_a, a, ROWS*COLUMNS*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, ROWS*COLUMNS*sizeof(int), cudaMemcpyHostToDevice);

    add<<<1,COLUMNS>>>(dev_a, dev_b);

    cudaMemcpy(b, dev_b, COLUMNS*sizeof(int), cudaMemcpyDeviceToHost);

    
    

}