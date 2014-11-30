#include "Opener.h"

#include <iostream>
using std::cout;
using std::endl;

extern __global__ void sumKernel( float *a, float *b, float *c );

void hnd(const cudaError_t &err) {
	if(err != cudaSuccess) 
		cout<<"cudaError_t = "<<cudaGetErrorString(err)<<endl;
}

void funcCuda( float *v1, int N1, float *v2, int N2, float* out, int N3 )
{
	typedef Opener<float, cudaMalloc, cudaFree> FloatOpener;
	
	Timer timer;
	timer.start();

	int N = N1 < N2 ? N1 : N2;

	float *v1Dev = NULL;
	float *v2Dev = NULL;
	float *outDev = NULL;

	FloatOpener op1(v1Dev,  N);
	FloatOpener op2(v2Dev,  N);
	FloatOpener op3(outDev, N);
	
	int numBytes = N*sizeof(float);
	
	hnd( cudaMemcpy( v1Dev, v1, numBytes, cudaMemcpyHostToDevice ) );
	hnd( cudaMemcpy( v2Dev, v2, numBytes, cudaMemcpyHostToDevice ) );
	
	dim3 threads = dim3(64, 1);
	dim3 blocks = dim3(N/threads.x, 1);

	sumKernel<<<blocks, threads>>>( v1Dev, v2Dev, outDev );

	hnd( cudaMemcpy( out, outDev, numBytes, cudaMemcpyDeviceToHost ) );

	timer.stop();
	cout<<"gpuTime = "<<timer.elapsed()<<endl;
}