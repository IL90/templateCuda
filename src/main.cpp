
#include <vector>
using std::vector;
#include <ctime>
#include <cstdlib>
#include <iostream>
using std::cout;
using std::endl;

extern void funcCuda( float *v1, int N1, float *v2, int N2, float *out, int N3 );

template<typename I>
void random( const I first, const I last ) 
{
	static bool flag = true;
	if (flag == true) 
	{
		srand( time(NULL) );
		flag = !flag;
	}

	for (I i = first; i != last; ++i)
		*i = rand() / (float) RAND_MAX;
}

int main( int, char const *[] )
{
	int N = 128;
	vector<float> v1(N);
	vector<float> v2(N);
	vector<float> out(N);

	for(int i = 0; i < N; ++i) {
		v1[i] = i;
		v2[i] = N - i;
	}

	//random( v1.begin(), v1.end() );
	//random( v2.begin(), v2.end() );
	
	funcCuda(&v1[0], N, &v2[0], N, &out[0], N );
	
	for(int i = 0; i < N; ++i)
		cout<<out[i]<<endl;
	cout<<"end"<<endl;
	return 0;
}