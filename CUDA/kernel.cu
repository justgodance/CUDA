#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <cstdlib>
#include <chrono>
#ifndef __CUDACC__  
#define __CUDACC__
#endif
#define NSIZE 8
__global__ void Mass(float* dA, float* dB, int size)
{
	int bx = blockIdx.x;
	int by = blockIdx.y;
	int tx = threadIdx.x;
	int ty = threadIdx.y; // определяем индексы нитей и блоков
	float res = 0;
	for (int k = 0; k < NSIZE-1; k++)
		if (dA[NSIZE * (blockDim.y * blockIdx.y + threadIdx.y) + k] != 0 && dA[NSIZE * (blockDim.y * blockIdx.y + threadIdx.y) + k + 1] != 0)
		{
			dB[NSIZE * (blockDim.y * blockIdx.y + threadIdx.y) + k] = 1;
				dB[NSIZE * (blockDim.y * blockIdx.y + threadIdx.y) + k + 1] = 1; //ищем пятна
		}
	for (int k = 0; k < NSIZE; k++)
	{
		if (dB[NSIZE * (blockDim.y * blockIdx.y + threadIdx.y) + k] != 0)
		res += dA[NSIZE * (blockDim.y * blockIdx.y + threadIdx.y) + k]; // считаем интенсивность
	}
	dA[NSIZE * (blockDim.y * blockIdx.y + threadIdx.y)]= res; // записываем интенсивность
}
int main()
{
	FILE* S1;
	S1 = fopen("RESULT.txt", "w");
	int i, j = 0, r, k = 0, f = 0, l = 0;
	float* hA, * hB; //hA - массив изначальных данных;hB - массив по поиску пятен
	float timerValueGPU, timerValueCPU; // измеряем время
	cudaEvent_t start, stop;
	cudaEventCreate(&start); cudaEventCreate(&stop);
	cudaEventRecord(start, 0);
	size_t size = sizeof(float) * NSIZE * NSIZE; //общий размер
	hA = (float*)malloc(size); 
	hB = (float*)malloc(size); // определяем массивы для CPU
	for (i = 0; i < NSIZE; i++) // цикл по заполнению массива данными
	{
		for (j = 0; j < NSIZE; j++)
		{
			r = rand() % 2;
			if (r == 0)
			{
				hA[j + i * NSIZE] = 0;
				printf("%0.0f  ", hA[j + i * NSIZE]);
			}
			else
			{
				hA[j + i * NSIZE] = rand()%8;
				printf("%0.0f  ", hA[j + i * NSIZE]);
			}
		}
	printf("\n");
	}
	float* dA = NULL;
	float* dB = NULL; 
	cudaMalloc((void**)&dA, size);
	cudaMalloc((void**)&dB, size); // определяем массивы для GPU 
	cudaMemcpy(dA, hA, size, cudaMemcpyHostToDevice); // копируем массив данных на GPU
	dim3 threads(NSIZE, 1);
	dim3 blocks(1, NSIZE); // определяем размер блоков
	printf("\n");
	Mass <<< blocks, threads >>> (dA, dB, size); // переходим в функцию ядро
	cudaMemcpy(hA, dA, size,cudaMemcpyDeviceToHost);
	cudaMemcpy(hB, dB, size, cudaMemcpyDeviceToHost); // копируем из GPU в CPU
	fprintf(S1, "INTENSITY \n");
	for (i = 0; i < NSIZE; i++)
	{
		fprintf(S1, "%0.0f  ", hA[i * NSIZE]);
		fprintf(S1, "\n");
	}
	fprintf(S1, "\n");
	for (i = 0; i < NSIZE; i++)
	{
		for (j = 0; j < NSIZE; j++)
			fprintf(S1, "%0.0f  ", hB[i * NSIZE+j]);
		fprintf(S1, "\n");
	}												  // заполняем файл данными
	cudaThreadSynchronize();
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&timerValueGPU, start, stop);
	printf("\n GPU calculation time %f msec\n", timerValueGPU); // проверяем время
	cudaFree(dB);									    
	cudaFree(dA);
	free(hA);
	free(hB); // освобождаем память
}


