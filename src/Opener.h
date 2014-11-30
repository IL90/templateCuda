#ifndef OPENER_H
#define OPENER_H

#include <iostream>
using std::cout;
using std::endl;

extern void hnd(const cudaError_t &err);

template<typename T, cudaError_t(*Malloc)(void**,size_t), cudaError_t(*Free)(void*)>
class Opener {
public:
	Opener(T* &t, int N) {
		hnd( Malloc( (void**)&t, N*sizeof(T) ) );
		t_ = t;
	}
	~Opener() {
		hnd( Free(t_) );
	}
private:
	T* t_;
};

template<typename T, cudaError_t(*Free)(void*)>
class Cleaner {
public:
	Cleaner(T *t) : t_(t) {}
	~Cleaner() {
		hnd( Free(t_) );
	}
private:
	T* t_;
};

class Timer {
public:
	Timer() : gpuTime_(0.0f) 
	{
		hnd( cudaEventCreate( &start_ ) );
		hnd( cudaEventCreate( &stop_  ) );
	}
	~Timer() 
	{
		hnd( cudaEventDestroy( start_ ) );
		hnd( cudaEventDestroy( stop_ ) );
	}
	void start() 
	{
		hnd( cudaEventRecord( start_, 0 ) );
	}
	void stop() 
	{
		hnd( cudaEventRecord( stop_, 0 ) );
		hnd( cudaEventSynchronize( stop_ ) );
		hnd( cudaEventElapsedTime( &gpuTime_, start_, stop_ ) );
	}
	float elapsed() const {return gpuTime_;}
private:
	cudaEvent_t start_, stop_;
	float gpuTime_;
};


#endif
