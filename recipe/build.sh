#!/bin/bash

mkdir -p build
cd build

if [ `uname` = "Linux" ]; then
    # there is a problem with NCSUopt when compiled with -fopenmp
    # so set the fflags manually:
    FFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe"
fi

cmake -D CMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
      -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX \
      -D DAKOTA_EXAMPLES_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_TEST_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_TOPFILES_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_PYTHON:BOOL=ON \
      -D DAKOTA_PYTHON_DIRECT_INTERFACE:BOOL=ON \
      -D DAKOTA_PYTHON_DIRECT_INTERFACE_NUMPY:BOOL=ON \
      -D HAVE_X_GRAPHICS:BOOL=OFF \
      -D DAKOTA_HAVE_MPI:BOOL=ON \
      -D DAKOTA_HAVE_HDF5:BOOL=ON \
      -D HAVE_QUESO:BOOL=ON \
      -D DAKOTA_HAVE_GSL=ON \
      -D ACRO_HAVE_DLOPEN:BOOL=OFF \
      -D DAKOTA_CBLAS_LIBS:BOOL=OFF \
      -D DAKOTA_INSTALL_DYNAMIC_DEPS:BOOL=OFF \
      -D Boost_NO_BOOST_CMAKE:BOOL=ON \
      -D DAKOTA_ENABLE_TESTS:BOOL=ON \
      -D DAKOTA_PYTHON_SURROGATES:BOOL=ON \
      ..

make VERBOSE=1 -j${CPU_COUNT} install
