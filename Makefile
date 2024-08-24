# Makefile

# Check if running as root
check_root:
	@if [ $$(id -u) -ne 0 ]; then \
		echo "This Makefile must be run as root or with sudo."; \
		exit 1; \
	fi

# Define the target installation directory
TARGET_DIR := /System

# Define the install target
install: check_root
	@if [ -d "/System" ]; then \
	  echo "System appears to be already installed."; \
	  exit 0; \
	else \
	if [ -d "/__w/system/system/" ]; then \
	  WORKDIR="/__w/system/system/"; \
	elif [ -d "/home/runner/work/system/system/" ]; then \
	  WORKDIR="/home/runner/work/system/system/"; \
	else \
	  WORKDIR=`pwd`; \
	fi; \
	mkdir -p /System/Library; \
	cp -R Library/* /System/Library; \
	. /System/Library/Preferences/GNUstep.conf; \
	CPUS=`nproc`; \
	export GNUSTEP_INSTALLATION_DOMAIN="SYSTEM"; \
	echo "CPUS is set to: $$CPUS"; \
	echo "SYSTEM is set to: $$GNUSTEP_INSTALLATION_DOMAIN"; \
	echo "WORKDIR is set to: $$WORKDIR"; \
	cd $$WORKDIR/tools-make && ./configure \
	  --enable-importing-config-file \
	  --with-config-file=/System/Library/Preferences/GNUstep.conf \
	  --with-library-combo=ng-gnu-gnu \
	&& gmake || exit 1 && gmake install; \
	. /System/Makefiles/GNUstep.sh; \
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
	cd $$WORKDIR/workspace && ./configure && gmake && gmake install; \
	cd $$WORKDIR/apps-systempreferences && gmake -j"${CPUS}" && gmake install; \
	cd $$WORKDIR/dubstep-dark-theme && gmake -j"${CPUS}" && gmake install; \
	cd $$WORKDIR && tar -cJvf system.txz $(TARGET_DIR); \
	fi;

# Define the uninstall target
uninstall: check_root
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

clean: check_root
	FILE=system.txz; \
	if [ -f $$FILE ]; then \
		echo "Removing $$FILE..."; \
		rm -f $$FILE; \
		echo "$$FILE removed successfully."; \
	else \
		echo "Nothing to clean."; \
	fi
