#!/bin/bash

set -ve

mkdir -p build
cd build

if [ `uname` = "Linux" ]; then
    # there is a problem with NCSUopt when compiled with -fopenmp
    # so set the fflags manually:
    FFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe"
    # implicit variables in Fortran code exclude the use of conda's environment variables
fi

if [ $mpi == "nompi" ]; then
    DAKOTA_HAVE_MPI=OFF
else
    DAKOTA_HAVE_MPI=ON
fi

echo "DAKOTA_HAVE_MPI=$DAKOTA_HAVE_MPI"

if [ ${build_type} == "Debug" ]; then
    FFLAGS=$(echo ${FFLAGS} | sed "s:-O2 ::g")
#   FORTRANFLAGS=$(echo ${DEBUG_FORTRANFLAGS} | sed "s:-O2 ::")
    CXXFLAGS=$(echo ${DEBUG_CXXFLAGS} | sed 's:-fvisibility-inlines-hidden ::')
    CPPFLAGS=$(echo ${DEBUG_CPPFLAGS} | sed 's:-fvisibility-inlines-hidden ::')
    CFLAGS=${DEBUG_CFLAGS}
    LDFLAGS=$(echo $LDFLAGS | sed 's:-Wl,-O2 ::')
    echo "+FFLAGS=$FFLAGS"
    echo "+FORTRANFLAGS=$FORTRANFLAGS"
    echo "+CXXFLAGS=$CXXFLAGS"
    echo "+CPPFLAGS=$CPPFLAGS"
    echo "+CFLAGS=$CFLAGS"
    echo "+LDFLAGS=$LDFLAGS"
fi

cmake -D CMAKE_BUILD_TYPE:STRING=${build_type} \
      -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX \
      -D DAKOTA_EXAMPLES_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_TEST_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_TOPFILES_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_PYTHON:BOOL=ON \
      -D DAKOTA_PYTHON_DIRECT_INTERFACE:BOOL=ON \
      -D DAKOTA_PYTHON_DIRECT_INTERFACE_NUMPY:BOOL=ON \
      -D HAVE_X_GRAPHICS:BOOL=OFF \
      -D DAKOTA_HAVE_MPI:BOOL=${DAKOTA_HAVE_MPI} \
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
