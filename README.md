# Sycl containers

Simple self-contained containers for SYCL developement, written per personal usage.

Contains:
* hipSYCL
* llvm 15.0.0
* DPC++ 
* CUDA 14.4
* oneMKL
* lapack
* oneTBB
* oneDNN

## Getting started

### Cuda docker
Before building the container, please make sure you have NVIDIA container toolkit properly set up. If you don't, first
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
docker build -t <IMAGE_NAME>
```

The image requires roughly 23 GB, make sure to have enough space. Also beware it takes roughly 2 hours to build.  


### Run

Once the image is build, just run it as follows

```shell
docker run -it --gpus all <IMAGE_NAME> bash
```

## Build a SYCL application
### HYPsycl on CPU or GPU


### DPC++ for Cuda
