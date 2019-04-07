#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N 8,000,000


void lowerNumber(int a[], low, high){
    int lowestNumber = a[low];
    for (int i = low; i < high; i++){
        if(a[i] < lowestNumber){
            lowestNumber = a[i];
        }
    }
    return lowestNumber;
}

int main(int argc, char * argv[]){
    int *a;
    int i;
    int rank, p;
    int tag = 0;
 
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &p);


    a = (int *) malloc(sizeof(int)*N);
    results = (int *) malloc(sizeof(int)*8);

    if (rank == 0){
        for(i = 0; i < N; i++)
            a[i] = rand() % 100000;
    }

    MPI_Bcast(a, N, MPI_INT, 0, MPI_COMM_WORLD);
    int numToMinimize = N / p;
    int low = rank * numToMinimize;
    int high = low + numToMinimize -1;
    int value = lowerNumber(a, temp, low, high)

    MPI_Barrier(MPI_COMM_WORLD);

    



}


