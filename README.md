# Gershwin System

This repository automates the installation of GNUstep components on Debian, utilizing submodules for a streamlined setup.

## Components Included

- **tools-scripts**: Utility scripts for setup and configuration.
- **tools-make**: Makefiles for building components.
- **libobjc2**: Objective-C runtime library.
- **swift-corelibs-libdispatch**: Swift's asynchronous task execution library.
- **libs-base**: Fundamental libraries for GNUstep.
- **libs-gui**: GUI libraries for graphical interface development.
- **libs-back**: Backend libraries for GNUstep.
- **apps-gworkspace**: GNUstep workspace application.
- **apps-systempreferences**: System preferences application.
- **dubstep-dark-theme**: Dark theme for the GNUstep environment.

## Installation Paths (SYSTEM domain)

These components are installed to the following directories within the SYSTEM domain:

- **Applications**: `/System/Applications`
- **Admin Applications**: `/System/Applications`
- **Web Applications**: `/System/WebApps`
- **Tools**: `/System/bin`
- **Admin Tools**: `/System/sbin`
- **Library**: `/System/lib`
- **Headers**: `/System/include`
- **Libraries**: `/System/lib`
- **Documentation**: `/System/Documentation`
- **Man Pages**: `/System/share/man`
- **Info Pages**: `/System/share/info`

## Usage (Debian)

Follow these steps to set up Gershwin System on Debian:

1. Clone the repository with submodules:

```
git clone https://github.com/gershwin-os/system.git --recurse-submodules
```

2. Install dependencies:
```
sudo ./system/tools-scripts/install-dependencies-linux
```

3. Build the components:
```
cd system && sudo ./build.sh
```