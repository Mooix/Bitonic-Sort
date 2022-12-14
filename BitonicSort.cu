#ifndef __CUDACC__  
#define __CUDACC__
#endif
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <random>


__global__ void bitonic(int* d_arr, int i, int j) {
	/*int index =  threadIdx.x;*/
	int index = threadIdx.x + (blockDim.x * blockIdx.x);
	int power = i - j + 1;
	int seq_length = pow(2, power);
	int skip = seq_length / 2;
	int x = pow(2, i);

	if (index % seq_length < skip) {
		if ((index / x) % 2 == 0) {
			if (d_arr[index] > d_arr[index + skip]) {
				int temp = d_arr[index];
				d_arr[index] = d_arr[index + skip];
				d_arr[index + skip] = temp;
			}

		}

		else if ((index / x) % 2 == 1) {
			if (d_arr[index] < d_arr[index + skip]) {
				int temp = d_arr[index];
				d_arr[index] = d_arr[index + skip];
				d_arr[index + skip] = temp;
			}
		}
	}
}

double my_log(double x, int base) {
	return log(x) / log(base);
}

void random_ints(int* arr, int N, int count) { // To fill the array
	int i;
	for (i = count; i < N; i++) {
		arr[i] = rand();
	}
}

int main() {
	
	int* arr, *arr_sorted; // Host copies
	int* d_arr; // Device copies
	
	int NumberOfBlocks = 3;
	int NumberOfThreads = 8;
	
	int N = NumberOfBlocks * NumberOfThreads;
	
	// To check if the input is applicable for log 2, if no we will add 0's in the first of array to resolve this issue
	int count = 0;
	while (true) {
		if (my_log(N, 2) > int(my_log(N, 2))) {
			count++;
			N++;
			NumberOfThreads++;
		}
		else {
			break;
		}
	}
	
	int size = N * sizeof(int);

	//Allocate space for device copies
	cudaMalloc((void**)&d_arr, size);
	
	//Allocate space for host copies
	arr = (int*)malloc(size);
	arr_sorted = (int*)malloc(size);

	//Fill array
	int x;
	for (x = 0; x < count; x++) {
		arr[x] = 0;
	}
	random_ints(arr, N, count);

	//Copy inputs from host to device
	cudaMemcpy(d_arr, arr, size, cudaMemcpyHostToDevice);
	
	printf("Original array\n\n");
	int i;
	int k = 0;
	for (i = count; i < N; i++) {
		printf("%d \t", arr[i]);
		if ((k++ + 1) % 5 == 0) {
			printf("\n");
		}
	}

	if (count != 0) {
		printf("\n-----------------------------------\n");
		printf("After we add 0's to make the input applicable for Bitonic sort\n\n");
		for (i = 0; i < N; i++) {
			printf("%d \t", arr[i]);
			if ((i + 1) % 5 == 0) {
				printf("\n");
			}
		}
	}

	//Run bitonic() kernel on GPU
	int j;
	for (i = 1; i <= my_log(N, 2); i++) {
		for (j = 1; j <= i; j++) {
			bitonic << <NumberOfBlocks, NumberOfThreads >> > (d_arr, i, j);
		}
	}

	//Copy result from device to the host
	cudaMemcpy(arr_sorted, d_arr, size, cudaMemcpyDeviceToHost);
	
	//Print array after the sort is completed
	printf("\n-----------------------------------\n");
	printf("Array after Bitonic Sort\n\n");
	//int i;
	j = 0;
	for (i = count; i < N; i++) {
		printf("%d \t", arr_sorted[i]);
		if ((j++ + 1) % 5 == 0) {
			printf("\n");
		}
	}
	printf("\n-----------------------------------\n");

	free(arr); free(arr_sorted);
	cudaFree(d_arr);
	return 0;

}