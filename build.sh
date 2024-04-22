#!/bin/sh

# Exit immediately if any command exits with a non-zero status
set -e

# Determine number of CPUs when building
CPUS=$(nproc)
export GNUSTEP_INSTALLATION_DOMAIN=SYSTEM
. /Developer/Makefiles/GNUstep.sh

if [ -f "/__w/system/system/root_amd64.zip" ]; then
  export SRC="/__w/system/system/"
fi

if [ -f "/home/runner/work/system/system/root_arm64.zip" ]; then
  export SRC="/home/runner/work/system/system/"  
fi

mkdir ${SRC}/swift-corelibs-libdispatch/Build
cd ${SRC}/swift-corelibs-libdispatch/Build && cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_INSTALL_PREFIX=/System \
  -DCMAKE_INSTALL_LIBDIR=/System/lib \
  -DCMAKE_INSTALL_MANDIR=/System/Documentation/man \
  -DINSTALL_PRIVATE_HEADERS=YES
gmake -j"${CPUS}" || exit 1
gmake install
rm /System/include/Block_private.h

mkdir ${SRC}/libobjc2/Build
cd ${SRC}/libobjc2/Build && pwd && ls && cmake .. \
  -DGNUSTEP_INSTALL_TYPE=SYSTEM \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++
gmake -j"${CPUS}" || exit 1
gmake install

cd ${SRC}/libs-base && ./configure --with-installation-domain=SYSTEM && gmake -j"${CPUS}" || exit 1 && gmake install
cd ${SRC}/libs-gui && ./configure && gmake -j"${CPUS}" || exit 1 || exit 1 && gmake install
cd ${SRC}/libs-back && ./configure && gmake -j"${CPUS}" || exit 1 && gmake install
cd ${SRC}/apps-gworkspace && ./configure && gmake && gmake install
cd ${SRC}/apps-systempreferences && gmake -j"${CPUS}" && gmake install
cd ${SRC}/dubstep-dark-theme && gmake -j"${CPUS}" && gmake install
