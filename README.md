# SYCL Containers

Self-contained containers for SYCL developement, originally written for personal usage.

## llvm-cuda
Contains:
  * llvm 15.0.0
  * DPC++ 
  * CUDA 14.4
  * oneMKL
  * Lapack
  * oneTBB
  * dpct (c2s)
  * boost 1.65

## hipSYCL
Contains:
  * hipSYCL (latest)
  * CUDA 14.4
  * llvm 13
  * oneMKL
  * boost 1.65

## oneAPI-cuda
Contains:
  * intel oneapi basekit (oneMKL, oneDPL, ...) 
  * CUDA 14.4
  * llvm 15.0.0
  * boost 1.65

## Getting started

Before building the container, please make sure you have the NVIDIA container toolkit properly set up. If you don't, first
setup the package repository and the GPG key:

```shell
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

then just run

```shell
sudo apt-get update
sudo apt-get install -y nvidia-docker2
```

and eventually restart the Docker daemon

```shell
sudo systemctl restart docker
```

### Build  

Let's assume you want to build `llvm-cuda`. Then run

```shell
docker build -f llvm-cuda/Dockerfile -t mspronesti/sycl-container:llvm-cuda .
```

The image requires roughly 23 GB, make sure to have enough space. Also beware it takes roughly 2 hours to build.  


### Run

Once the image is build, just run it as follows

```shell
docker run -it --gpus all mspronesti/sycl-container:llvm-cuda bash
```

## Build a SYCL application on NVidia GPU
 
Once you got a shell, write your code or clone it from wherever it is and compile it making sure to use `clang++` as compiler and to specify the following compilation options, among the others, in you Makefile or CMakeLists

```shell
-fsycl -fsycl-targets=nvptx64-nvidia-cuda
```

## Build a SYCL application using HipSYCL on NVidia GPU or OMP.

Compile it using `syclcc`, specifying the extra option `--hipsycl-gpu-arch`. For instance

```shell
syclcc --hipsycl-gpu-arch=sm_75 dummy.cpp -o dummy
```

If you want instead to run it on CPU, specify `--hipsycl-targets`.
 
```shell
syclcc --hipsycl-targets=omp dummy.cpp -o dummy
```
Alternatively, export `HIPSYCL_TARGETS` before compiling. For instance

```shell
export HIPSYCL_TARGETS=cuda:sm_75
```

