#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Determine number of CPUs when building
CPUS=$(nproc)
export GNUSTEP_INSTALLATION_DOMAIN=SYSTEM
. /Developer/Makefiles/GNUstep.sh

mkdir swift-corelibs-libdispatch/Build
cd swift-corelibs-libdispatch/Build && cmake .. \
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

mkdir libobjc2/Build
cd libobjc2/Build && cmake .. \
  -DGNUSTEP_INSTALL_TYPE=SYSTEM \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++
gmake -j"${CPUS}" || exit 1
gmake install

cd libs-base && ./configure --with-installation-domain=SYSTEM && gmake -j"${CPUS}" || exit 1 && gmake install
cd libs-gui && ./configure && gmake -j"${CPUS}" || exit 1 || exit 1 && gmake install
cd libs-back && ./configure && gmake -j"${CPUS}" || exit 1 && gmake install
cd apps-gworkspace && ./configure && gmake && gmake install
cd apps-systempreferences && gmake -j"${CPUS}" && gmake install
cd dubstep-dark-theme && gmake -j"${CPUS}" && gmake install
cd dubstep-dark-theme && gmake -j"${CPUS}" && gmake install
cd gs-terminal && gmake -j"${CPUS}" && gmake install