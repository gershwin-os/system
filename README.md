# Gershwin System

This repository automates the installation of GNUstep components on Debian, utilizing submodules for a streamlined setup.

# Requirements

Gershwin has been tested and confirmed to work on the following platforms:

* Debian 12
* FreeBSD 14

Since Gershwin leverages GNUstep, it should, in theory, be compatible with any platform supported by GNUstep.

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
- **Tools**: `/System/bin`
- **Admin Tools**: `/System/sbin`
- **Library**: `/System/lib`
- **Headers**: `/System/include`
- **Libraries**: `/System/lib`
- **Documentation**: `/System/Documentation`
- **Man Pages**: `/System/share/man`
- **Info Pages**: `/System/share/info`

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
/System/Library/Scripts/Gershwin-X11
```