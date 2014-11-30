#include "Opener.h"

#include <iostream>
using std::cout;
using std::endl;

extern __global__ void sumKernel( float *a, float *b, float *c );

void hnd(const cudaError_t &err) {
	if(err != cudaSuccess) 
		cout<<"cudaError_t = "<<cudaGetErrorString(err)<<endl;
}

void print(const cudaDeviceProp &prop) 
{
	cout<<"\n###Device Properties###"<<endl;
	
	cout<<"Name: "<<prop.name<<endl;
	cout<<"Capability: "<<prop.major<<"."<<prop.minor<<endl;
	cout<<"Clock Rate: "<<prop.clockRate<<endl;
	cout<<"Overlap: "<<prop.deviceOverlap<<endl;
	cout<<"Timeout Enabled: "<<prop.kernelExecTimeoutEnabled<<endl;

	cout<<"Total Global Memory: "<<prop.totalGlobalMem<<endl;
	cout<<"Total Constant Memory: "<<prop.totalConstMem<<endl;
	cout<<"Max Memory Pitch: "<<prop.memPitch<<endl;
	cout<<"Texture Alignment: "<<prop.textureAlignment<<endl;

	cout<<"MultiProcessor Count: "<<prop.multiProcessorCount<<endl;
	cout<<"Shared Memory per MP: "<<prop.sharedMemPerBlock<<endl;
	cout<<"Registers per Block: "<<prop.regsPerBlock<<endl;
	cout<<"Warp Size: "<<prop.warpSize<<endl;
	cout<<"Max Threads per Block: "<<prop.maxThreadsPerBlock<<endl;

	cout<<"Max Threads Dim ("<<prop.maxThreadsDim[0]<<", "<<prop.maxThreadsDim[1]<<", "<<prop.maxThreadsDim[2]<<")"<<endl;
	cout<<"Max Grid Size ("<<prop.maxGridSize[0]<<", "<<prop.maxGridSize[1]<<", "<<prop.maxGridSize[2]<<")"<<endl;
}

void properties() 
{
	cout<<"properties"<<endl;
	
	int count;
	hnd( cudaGetDeviceCount( &count ) );
	
	cudaDeviceProp prop;

	for (int i = 0; i < count; ++i) 
	{
		hnd( cudaGetDeviceProperties( &prop, i ) );
		print(prop);
	}

}

void funcCuda( float *v1, int N1, float *v2, int N2, float* out, int N3 )
{
	typedef Opener<float, cudaMalloc, cudaFree> FloatOpener;
	properties();
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
