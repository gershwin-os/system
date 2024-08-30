# Gershwin System

Gershwin is an OS X-like environment created using GNUstep, an open-source framework that closely mirrors Apple's Cocoa framework. 

# Requirements

Gershwin has been tested and confirmed to work on the following platforms:

* Debian 12
* FreeBSD 14

Since Gershwin leverages GNUstep, it should, in theory, be compatible with any platform supported by GNUstep.

Additionally the following packages must be installed to run Gershwin:

* xorg

## Components Included

- **tools-scripts**: Utility scripts for setup and configuration.
- **tools-make**: Makefiles for building components.
- **libobjc2**: Objective-C runtime library.
- **libs-base**: Fundamental libraries for GNUstep.
- **libs-gui**: GUI libraries for graphical interface development.
- **libs-back**: Backend libraries for GNUstep.
- **gworkspace**: GNUstep GWorkspace fork with modifications for OS X style layout.
- **apps-systempreferences**: System preferences application.
- **dubstep-dark-theme**: Dark theme for the GNUstep environment.

## Installation Paths (SYSTEM domain)

These components are installed to the following directories within the SYSTEM domain:

- **Applications**: `/System/Applications`
- **Admin Applications**: `/System/Applications`
- **Web Applications**: `/System/WebApps`
- **Tools**: `/System/Tools`
- **Admin Tools**: `/System/Tools/Admin`
- **Library**: `/System/Library`
- **Headers**: `/System/Library/Headers`
- **Libraries**: `/System/Library/Libraries`
- **Documentation**: `/System/Library/Documentation`
- **Man Pages**: `/System/Library/Documentation/man`
- **Info Pages**: `//System/Library/Documentation/info`

## Installation for Debian

Follow these steps to set up Gershwin System on Linux:

1. Clone the repository with submodules:

```
git clone https://github.com/gershwin-os/system.git --recurse-submodules
```

2. Install dependencies:
```
cd system && sudo ./tools-scripts/install-dependencies-linux
```

3. Install using make:
```
sudo make install
```

## Installation for FreeBSD

Follow these steps to set up Gershwin System on Linux:

1. Clone the repository with submodules:

```
git clone https://github.com/gershwin-os/system.git --recurse-submodules
```

2. Install dependencies:
```
cd system && sudo ./tools-scripts/install-dependencies-freebsd
```

3. Install using make:
```
sudo make install
```

## Uninstallation

```
sudo make uninstall
```

## Cleanup

This command will remove the system.txz tar archive:

```
sudo make clean
```

## Usage

1. Source GNUstep.sh:
```
. /System/Makefiles/GNUstep.sh 
```

2. Launch Workspace:
```
startx /System/Library/Scripts/Gershwin-X11
```