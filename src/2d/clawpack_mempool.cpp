#ifdef _OPENMP
#include <omp.h>
#endif

#include <iostream>
#include <limits>
#include <algorithm>
#include <new>
#include <memory>
#include <vector>
#include <cstring>
#include <cstdint>
#include <cassert>


#ifdef CUDA
#include "clawpack_GPUMemoryManager.H"
#include "clawpack_CPUPinnedMemoryManager.H"
#include "clawpack_CUDA_helper.H"
// #include <cuda_runtime_api.h>
#endif

#include "clawpack_mempool.H"

// static vector<std::unique_ptr<CArena> > the_memory_pool;

#ifdef CUDA
// Each GPUMemoryManager manages memory in one GPU
// device_memory_pool[i] manages memory in GPU i
static std::vector<std::unique_ptr<GPUMemoryManager>> device_memory_pool;

// CPUPinnedMemoryManager manages pinned (unpageable) CPU memory for asynchronous 
// data transfer between CPU and GPU
static std::unique_ptr<CPUPinnedMemoryManager> pinned_memory_pool;
#endif

#if defined(CLAWPACK_TESTING) || defined(DEBUG)
static int init_snan = 1;
#else
static int init_snan = 0;
#endif

static bool local_verbose = false;

extern "C" {

void clawpack_mempool_init()
{
    static bool initialized = false;
    if (!initialized)
    {
        if (local_verbose)
            std::cout << "clawpack_mempool_init() called" << std::endl;
	initialized = true;

 
// CPU memory pool
// #ifdef _OPENMP
// 	int nthreads = omp_get_max_threads();
// #else
// 	int nthreads = 1;
// #endif
// 	the_memory_pool.resize(nthreads);
// 	for (int i=0; i<nthreads; ++i) {
// 	    the_memory_pool[i].reset(new CArena);
// 	}
// #ifdef _OPENMP
// #pragma omp parallel
// #endif
// 	{
// 	    size_t N = 1024*1024*sizeof(double);
// 	    void *p = amrex_mempool_alloc(N);
// 	    memset(p, 0, N);
// 	    amrex_mempool_free(p);
// 	}



#ifdef CUDA
        int num_devices = get_num_devices_used();
	device_memory_pool.resize(num_devices);
	for (int i=0; i<num_devices; ++i) {
	    device_memory_pool[i].reset(new GPUMemoryManager(i,0));
	}

        // TODO: If one of the devices does not have enough memory
        // because other processes are running, this will cause 
        // cudaMalloc to fail.
	// for (int i=0; i<num_devices; ++i) {
        //     size_t sz = 1024*1024*512;
        //     void* vp_d = clawpack_mempool_alloc_gpu(sz,i);
        //     clawpack_mempool_free_gpu(vp_d,i);
        // }

        pinned_memory_pool.reset(new CPUPinnedMemoryManager(0));
        // allocate 1 GB of pinned memory at the beginning
        void* vp = clawpack_mempool_alloc_pinned(1024*1024*1024);
        clawpack_mempool_free_pinned(vp);
#endif
    }
}

void clawpack_mempool_finalize()
{
    static bool finalized = false;
    if (!finalized)
    {
        if (local_verbose)
            std::cout << "clawpack_mempool_finalize() called" << std::endl;
	finalized = true;
        // TODO: I should clean up all memory requested by GPUMemoryManager
        // from the system here 
        // Because it seems like the destructor of GNUMemoryManager is 
        // never called before the CUDA context is destroyed at the end
        // This is fine because all GPU memory will be recollected by 
        // GPU driver when CUDA context is destroyed but looks not nice
    }
}

/*
void* amrex_mempool_alloc (size_t nbytes)
{
  void* pt;
#ifdef _OPENMP
  int tid = omp_get_thread_num();
#else
  int tid = 0;
#endif
  pt = the_memory_pool[tid]->alloc(nbytes);

  return pt;
}


void amrex_mempool_free (void* p) 
{
#ifdef _OPENMP
  int tid = omp_get_thread_num();
#else
  int tid = 0;
#endif

  the_memory_pool[tid]->free(p);
}
*/

#ifdef CUDA

void* clawpack_mempool_alloc_pinned (size_t nbytes)
{
  return pinned_memory_pool->alloc_pinned(nbytes);
}

void clawpack_mempool_free_pinned (void* p) 
{
  pinned_memory_pool->free_pinned(p);
}

void* clawpack_mempool_alloc_gpu (size_t nbytes, int device_id)
{

    assert(device_id >= 0);
    return device_memory_pool[device_id]->alloc_device(nbytes, device_id);
}

void clawpack_mempool_free_gpu (void* p, int device_id) 
{
    assert(device_id >= 0);
    device_memory_pool[device_id]->free_device(p, device_id);
}

/*
void* amrex_mempool_alloc_gpu_hold (size_t nbytes, int tag, int device_id)
{

    BL_ASSERT(device_id >= 0);
    return device_memory_pool[device_id]->alloc_device(nbytes, tag, device_id);
}
*/

#endif

void clawpack_real_array_init (double* p, size_t nelems)
{
    if (init_snan) clawpack_array_init_snan(p, nelems);
}

void clawpack_array_init_snan (double* p, size_t nelems)
{
#ifdef UINT64_MAX
    const uint64_t snan = UINT64_C(0x7ff0000080000001);
#else
    static_assert(sizeof(double) == sizeof(long long), "MemPool: sizeof double != sizeof long long");
    const long long snan = 0x7ff0000080000001LL;
#endif
    for (size_t i = 0; i < nelems; ++i) {
        std::memcpy(p++, &snan, sizeof(double));
    }
}

/*
void amrex_mempool_get_stats (int& mp_min, int& mp_max, int& mp_tot) // min, max & tot in MB
{
  size_t hsu_min=std::numeric_limits<size_t>::max();
  size_t hsu_max=0;
  size_t hsu_tot=0;
  for (const auto& mp : the_memory_pool) {
    size_t hsu = mp->heap_space_used();
    hsu_min = std::min(hsu, hsu_min);
    hsu_max = std::max(hsu, hsu_max);
    hsu_tot += hsu;
  }
  mp_min = hsu_min/(1024*1024);
  mp_max = hsu_max/(1024*1024);
  mp_tot = hsu_tot/(1024*1024);
}



*/

}

/*
 * Below are C functions, not Fortran
 */

// #ifdef CUDA
// void CUDART_CB cudaCallback_release_gpu(cudaStream_t event, cudaError_t status, void *data){
//     checkCudaErrors(status);
//     // TODO add device_id
//     int* tag = (int*) data;
//     amrex_mempool_release_gpu(*tag, 0);
// }
// 
// void amrex_mempool_release_gpu (int tag, int device_id) 
// {
//     // free all GPU memories associated with tag
//     BL_ASSERT(device_id >= 0);
//     device_memory_pool[device_id]->free_device_tag(tag, device_id);
// }
// #endif
