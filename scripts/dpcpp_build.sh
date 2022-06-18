#!/bin/bash

# export vars
# set CUDA_ROOT appropriately if the local of cuda changes
# set DPCPP_HOME to a different location if you want to install
# the required dependencies for the cross  compilation on NVidia GPU elsewhere
export DPCPP_HOME=/dpcpp_cuda
export CUDA_ROOT=/usr/local/cuda-11.4
export CUDA_LIB_PATH=${CUDA_ROOT}/lib64/stubs


_install_spirv_tools_ () {
  cd $DPCPP_HOME
  (if cd SPIRV-Tools; then git pull; else git clone https://github.com/KhronosGroup/SPIRV-Tools.git; fi)
  cd SPIRV-Tools
  (cd external ; (if cd SPIRV-Headers; then git pull; else git clone https://github.com/KhronosGroup/SPIRV-Headers.git; fi))
  (cd external ; (if cd googletest; then git pull; else git clone https://github.com/google/googletest.git; fi))
  (cd external ; (if cd effcee; then git pull; else git clone https://github.com/google/effcee.git; fi))
  (cd external ; (if cd re2; then git pull; else git clone https://github.com/google/re2.git; fi))
  
  mkdir build 
  cd build 
  cmake \
    -DCMAKE_INSTALL_PREFIX=$DPCPP_HOME/deploy \
    -DSPIRV_WERROR=OFF \
    -DCMAKE_BUILD_TYPE=Release \ 
    ..
  make install -j `nproc`
}


_install_opencl_headers_ () {
   cd $DPCPP_HOME
   git clone https://github.com/KhronosGroup/OpenCL-Headers
   cmake -D CMAKE_INSTALL_PREFIX=./OpenCL-Headers/install -S ./OpenCL-Headers -B ./OpenCL-Headers/build
   cmake --build ./OpenCL-Headers/build --target install
}


_install_opencl_loader_ () {
   cd $DPCPP_HOME
   git clone https://github.com/KhronosGroup/OpenCL-ICD-Loader

   cmake -D CMAKE_PREFIX_PATH=$DPCPP_HOME/OpenCL-Headers/install -D CMAKE_INSTALL_PREFIX=./OpenCL-ICD-Loader/install -S ./OpenCL-ICD-Loader -B ./OpenCL-ICD-Loader/build

    cmake --build ./OpenCL-ICD-Loader/build --target install
}

# install clang++ compiler compatible with NVidia hardware, 
# provided by llvm
_install_llvm_clang_ () {
 cd $DPCPP_HOME
 TARGETS_TO_BUILD="AMDGPU;NVPTX;X86"
	
 git clone --config core.autocrlf=false https://github.com/intel/llvm -b sycl
 cd llvm
 python ./buildbot/configure.py --cuda \
	 -t release \
	 --cmake-opt="-DCMAKE_INSTALL_PREFIX=$DPCPP_HOME/deploy" \
	 --cmake-opt="-DLLVM_ENABLE_DUMP=OFF" \
	 --cmake-opt="-DLLVM_ENABLE_ASSERTIONS=OFF" \
	 --cmake-opt="-DLLVM_TARGETS_TO_BUILD=$TARGETS_TO_BUILD" \
	 --cmake-opt="-DCLANG_ANALYZER_ENABLE_Z3_SOLVER=0" \
	 --cmake-opt="-DLLVM_INCLUDE_BENCHMARKS=0" \
	 --cmake-opt="-DLLVM_ENABLE_OCAMLDOC=OFF" \
	 --cmake-opt="-DLLVM_ENABLE_BINDINGS=OFF" \
	 --cmake-gen "Unix Makefiles"

 cd build
 make sycl-toolchain -j `nproc`
 make install
}

_install_lapack_ () {
  # a fortran compiler is needed for lapack
  sudo apt-get install gfortran
 
  cd $DPCPP_HOME
  (if cd lapack; then git pull; else git clone https://github.com/Reference-LAPACK/lapack.git; fi)
  cd lapack/
  mkdir -p build
  cd build/
  cmake \
     -DCMAKE_INSTALL_LIBDIR=$HOME/.local/lapack \
     -DBUILD_SHARED_LIBS=ON \
     -DCBLAS=ON \
     ..
  cmake --build . -j --target install
}

_install_tbb_ () {
  cd $DPCPP_HOME
  (if cd oneTBB; then git pull; else git clone https://github.com/oneapi-src/oneTBB.git; fi)
  cd oneTBB
  mkdir -p build
  cd build
  cmake \
   -DCMAKE_CXX_COMPILER=$DPCPP_HOME/deploy/bin/clang++ \
   -DCMAKE_BUILD_TYPE=Release \
   -DTBB_STRICT=OFF \
   -DCMAKE_INSTALL_PREFIX=$DPCPP_HOME/deploy/ \
   ..
   make install -j $(nproc)
}

_install_mkl_ () {
  # install libatlas first 
  #sudo apt install libatlas-base-dev

  cd $DPCPP_HOME
  git clone https://github.com/oneapi-src/oneMKL.git
  cd oneMKL
  mkdir -p build
  cd build
  # https://oneapi-src.github.io/oneMKL/building_the_project.html#building-with-cmake
  # go to "building for cuda"
  echo "Building oneMKL. This is gonna be slow ..."
  cmake \
    -DCMAKE_CXX_COMPILER=$DPCPP_HOME/deploy/bin/clang++ \
    -DCMAKE_CXX_FLAGS=-I$DPCPP_HOME/lapack/CBLAS/include \
    -DCMAKE_C_FLAGS=-I$DPCPP_HOME/lapack/CBLAS/include \
    -DTARGET_DOMAINS=blas \
    -DENABLE_MKLGPU_BACKEND=False \
    -DENABLE_MKLCPU_BACKEND=False \
    -DENABLE_CUBLAS_BACKEND=True \
    -DREF_BLAS_ROOT=$DPCPP_HOME/lapack/install \
    -DOPENCL_INCLUDE_DIR=$DPCPP_HOME/OpenCL-Headers \
    -DCUDA_TOOLKIT_ROOT_DIR=$CUDA_ROOT \
    -DSYCL_LIBRARY=$DPCPP_HOME/deploy/lib/libsycl.so \
    ..

   cmake --build .
   # install	 
   cmake --install . --prefix $DPCPP_HOME/deploy/
}

_install_dpct_ () {
  cd $DPCPP_HOME
  git clone https://github.com/oneapi-src/SYCLomatic.git
  cd SYCLomatic
  mkdir build
  cd build
  cmake -G Ninja \
	-DCMAKE_INSTALL_PREFIX=$DPCPP_HOME/deploy/ \
	-DCMAKE_BUILD_TYPE=Release \
       	-DLLVM_ENABLE_PROJECTS="clang" \
      	-DLLVM_TARGETS_TO_BUILD="X86;NVPTX" \
	../llvm

  # install with ninja
  ninja install-c2s
}

mkdir $DPCPP_HOME
cd $DPCPP_HOME

_install_spirv_tools_
_install_opencl_headers_
_install_opencl_loader_
_install_llvm_clang_
_install_lapack_
_install_tbb_
_install_mkl_
_install_dpct_
