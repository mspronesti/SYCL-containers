# SYCL Containers

Self-contained containers for SYCL developement, originally written per personal usage.

Contains:
* llvm 15.0.0
* DPC++ 
* CUDA 14.4
* oneMKL
* lapack
* oneTBB
* dpct (c2s)

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

Build the image running

```shell
docker build -f dpcpp_cuda/Dockerfile -t mspronesti/sycl-container:dpcpp-cuda .
```

The image requires roughly 23 GB, make sure to have enough space. Also beware it takes roughly 2 hours to build.  


### Run

Once the image is build, just run it as follows

```shell
docker run -it --gpus all mspronesti/sycl-container:dpcpp-cuda bash
```

## Build a SYCL application on NVidia GPU
 
Once you got a shell, run the `dpcpp_setvars.sh` script located under your root folder

```shell
source dpcpp_setvars.sh
```

Then just write your code or clone it from wherever it is and compile it making sure to use `clang++` as compiler and to specify the following compilation options, among the others, in you makefiles or cmakefiles.

```shell
-fsycl -fsycl-targets=nvptx64-nvidia-cuda
```


