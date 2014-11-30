
__global__ void sumKernel( float *a, float *b, float *c )
{
	int idx = threadIdx.x + blockIdx.x*blockDim.x;
	c[idx] = a[idx] + b[idx];
}