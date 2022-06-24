FROM intel/oneapi-basekit

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    sudo \
    vim \ 
    wget \
    --

ARG GIT_SSL_NO_VERIFY=1

RUN apt-get install -y ninja-build libboost-all-dev

# Install Cuda-11.4
RUN echo "Installing Cuda..." \
	&& wget -q https://developer.download.nvidia.com/compute/cuda/11.4.0/local_installers/cuda_11.4.0_470.42.01_linux.run \
	&& chmod +x cuda_11.4.0_470.42.01_linux.run \
	&& ./cuda_11.4.0_470.42.01_linux.run --toolkit --silent --toolkitpath=/usr/local/cuda-11.4 \
	&& rm -rf cuda_11.4.0_470.42.01_linux.run

# Install gcc-9/10 and g++-9/10
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test \
	&& apt update \
	&& apt install -y gcc-9 g++-9

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9 \
	&&  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9

RUN apt install -y gcc-11 g++-11 \
	&& update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11 \
	&&  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 11 \
	&& update-alternatives --auto gcc \
	&& update-alternatives --auto g++


# build llvm for cuda
ENV DPCPP_HOME="/dpcpp"
RUN mkdir ${DPCPP_HOME} && cd ${DPCPP_HOME} 

RUN cd ${DPCPP_HOME} \
    && git clone --config core.autocrlf=false https://github.com/intel/llvm -b sycl \
    && cd llvm \
    &&  python ./buildbot/configure.py --cuda \
         -t release \
         --cmake-opt="-DCMAKE_INSTALL_PREFIX=${DPCPP_HOME}" \
         --cmake-opt="-DCMAKE_LIBRARY_PATH=/usr/local/cuda-11.4/lib64/stubs" \
         --cmake-opt="-DLLVM_ENABLE_DUMP=OFF" \
         --cmake-opt="-DLLVM_ENABLE_ASSERTIONS=OFF" \
         --cmake-opt="-DLLVM_TARGETS_TO_BUILD=NVPTX;X86" \
         --cmake-opt="-DLLVM_INCLUDE_BENCHMARKS=0" \
         --cmake-opt="-DLLVM_ENABLE_OCAMLDOC=OFF" \
         --cmake-opt="-DLLVM_ENABLE_BINDINGS=OFF" \
         --cmake-opt="-DLLVM_BUILD_TESTS=OFF" \
         --cmake-gen "Unix Makefiles" \
   && cd build \
   && make sycl-toolchain -j `nproc` \
   && make install


ENV PATH=/usr/local/cuda/bin:/usr/local/cuda/nvvm/bin:${DPCPP_HOME}/llvm/build/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/nvvm/lib64:${DPCPP_HOME}/llvm/build/lib:$LD_LIBRARY_PATH

