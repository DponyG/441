//    Samuel Grenon
//    CS 443 
//    Dr. Mock
//    Problem 1:

#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>


int lowerNumber(int a[], int low ,int high);

#define N 8000000


int lowerNumber(int a[], int low, int high){
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
    int testMin = INT_MAX;
    int min = INT_MAX;
    int source;
    MPI_Status status;
 
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &p);


    a = (int *) malloc(sizeof(int)*N);

    if (rank == 0){
        for(i = 0; i < N; i++) {
            a[i] = rand() % 100000;
            if (testMin > a[i]){
                testMin = a[i];
            } 
        }
        printf("The minimum value is: %d \n", testMin);
    }

    MPI_Bcast(a, N, MPI_INT, 0, MPI_COMM_WORLD);
    int numToMinimize = N / p;
    int low = rank * numToMinimize;
    int high = low + numToMinimize -1;
    int processValue = lowerNumber(a, low, high);

    MPI_Barrier(MPI_COMM_WORLD);



    if(rank != 0) {
        MPI_Send(&processValue, 1, MPI_INT, 0, tag, MPI_COMM_WORLD);
    }

    else if (rank == 0) {
        if (min > processValue){
            min = processValue;
        }

        for (source = 1; source <p; source ++){
            MPI_Recv(&processValue, 1, MPI_INT, source, tag, MPI_COMM_WORLD,&status);
            if(min > processValue){
                min = processValue;
            }
        }

        printf("The MPI value is: %d \n", min);

    }

    free(a);
    MPI_Finalize();
    return 0;   
}


