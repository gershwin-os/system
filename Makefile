# Makefile

# Root check
ifeq ($(shell id -u), 0)
else
$(error This Makefile must be run as root or with sudo)
endif

# Define variables
CPUS := $(shell nproc)
GNUSTEP_INSTALLATION_DOMAIN := SYSTEM
export GNUSTEP_INSTALLATION_DOMAIN

# Debug output
$(info CPUS is set to: ${CPUS})

# Define the install target
install:
	@if [ -d "/System" ]; then \
	  echo "System appears to be already installed."; \
	  exit 0; \
	else \
	if [ -d "/__w/system/system/" ]; then \
	  WORKDIR="/__w/system/system/"; \
	elif [ -d "/home/runner/work/system/system/" ]; then \
	  WORKDIR="/home/runner/work/system/system/"; \
	else \
	  WORKDIR="$(shell pwd)"; \
	fi; \
	echo "WORKDIR is set to: $$WORKDIR"; \
	cd $$WORKDIR/tools-make && ./configure \
	  --enable-importing-config-file \
	  --with-config-file=/Library/Preferences/GNUstep.conf \
	  --with-library-combo=ng-gnu-gnu \
	&& gmake || exit 1 && gmake install; \
	. /Developer/Makefiles/GNUstep.sh; \
	mkdir -p $$WORKDIR/swift-corelibs-libdispatch/Build; \
	cd $$WORKDIR/swift-corelibs-libdispatch/Build && cmake .. \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_C_COMPILER=clang \
	  -DCMAKE_CXX_COMPILER=clang++ \
	  -DCMAKE_INSTALL_PREFIX=/System \
	  -DCMAKE_INSTALL_LIBDIR=/System/lib \
	  -DCMAKE_INSTALL_MANDIR=/System/Documentation/man \
	  -DINSTALL_PRIVATE_HEADERS=YES; \
	gmake -j"${CPUS}" || exit 1; \
	gmake install; \
	rm /System/include/Block_private.h; \
	mkdir -p $$WORKDIR/libobjc2/Build; \
	cd $$WORKDIR/libobjc2/Build && pwd && ls && cmake .. \
	  -DGNUSTEP_INSTALL_TYPE=SYSTEM \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_C_COMPILER=clang \
	  -DCMAKE_CXX_COMPILER=clang++; \
	gmake -j"${CPUS}" || exit 1; \
	gmake install; \
	cd $$WORKDIR/libs-base && ./configure --with-installation-domain=SYSTEM && gmake -j"${CPUS}" || exit 1 && gmake install; \
	cd $$WORKDIR/libs-gui && ./configure && gmake -j"${CPUS}" || exit 1 || exit 1 && gmake install; \
	cd $$WORKDIR/libs-back && ./configure && gmake -j"${CPUS}" || exit 1 && gmake install; \
	cd $$WORKDIR/apps-gworkspace && ./configure && gmake && gmake install; \
	cd $$WORKDIR/apps-systempreferences && gmake -j"${CPUS}" && gmake install; \
	cd $$WORKDIR/dubstep-dark-theme && gmake -j"${CPUS}" && gmake install; \
	cd $$WORKDIR && ARCH=$$(dpkg --print-architecture) && tar -czvf gershwin-system-$$ARCH.tar.gz /System; \
	fi;

# Define the uninstall target
uninstall:
	@removed=""; \
	if [ -d "/System" ]; then \
	  rm -rf /System; \
	  removed="/System"; \
	  echo "Removed /System"; \
	fi; \
	if [ -n "$$removed" ]; then \
	  return 0; \
	else \
	  echo "System appears to be already uninstalled.  Nothing was removed"; \
	fi

clean:
	@ARCH=$(shell dpkg --print-architecture); \
	FILE=gershwin-system-$$ARCH.tar.gz; \
	if [ -f $$FILE ]; then \
		echo "Removing $$FILE..."; \
		rm -f $$FILE; \
		echo "$$FILE removed successfully."; \
	else \
		echo "Nothing to clean."; \
	fi