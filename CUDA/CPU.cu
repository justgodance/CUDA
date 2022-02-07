
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <cstdlib>
#include <chrono>
#define size 1024
int main()
{
	auto begin = std::chrono::steady_clock::now();
	FILE* S1;
	S1 = fopen("RESULT.txt", "w");
	int i, j = 0, r, k = 0, f = 0, l = 0;
	float sum = 0;
	float** a;
	float** b;
	a = new float* [size];
	b = new float* [size];
	for (i = 0; i < size; i++)
	{
		a[i] = new float[size];
		b[i] = new float[size];
	}
	for (i = 0; i < size; i++)
		for (j = 0; j < size; j++)
		{
			r = rand() % 2;
			if (r == 0)
				a[i][j] = 0;
			else
				a[i][j] = rand()%8;
			b[i][j] = 1;
			//printf("%0.0f", a[i][j]);
		}
	for (i = 0; i < size; i++)
		for (j = 0; j < size; j++)
		{
			if ((a[i][j - 1] == 0 && a[i][j + 1] == 0) || a[i][j] == 0/*||a[i][j]<s/n*/)
			{
				b[i][j] = 0;
			}
		}
	for (i = 0; i < size; i++)
	{
		for (j = 0; j < size; j++)
			fprintf(S1, "%0.0f ", b[i][j]);
		fprintf(S1, "\n");
	}
	for (i = 0; i < size; i++)
	{
		for (j = 0; j < size ; j++)
		{
			if (b[i][j] != 0)
				sum += a[i][j];
		}
		a[i][0] = sum;
		sum = 0;
	}
	for (i = 0; i < size; i++)
		{
		fprintf(S1, "%0.0f\n", a[i][0]);
		}
	auto end = std::chrono::steady_clock::now();
	auto elapsed_ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - begin);
	std::cout << "The time: " << elapsed_ms.count() << " ms\n";
}
