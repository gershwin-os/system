# GNUMakefile for usermigrate

# Define the tool name and source files
TOOL_NAME = usermigrate
TOOL_SRC = usermigrate.m

# GNUstep configuration for compiling Objective-C
GNUSTEP_INSTALLATION_DOMAIN = SYSTEM
GNUSTEP_MAKEFILES = /System/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make

# Objective-C flags and libraries
ADDITIONAL_OBJCFLAGS = -Wall
ADDITIONAL_LDFLAGS = -L$(GNUSTEP_INSTALLATION_DIR)/Library/Libraries -lgnustep-base

# Installation directories
INSTALL_DIR = /System/Tools

# Installation directory for the tool
TOOL_INSTALL_DIR = $(INSTALL_DIR)

# Default target to build the tool
all: $(TOOL_NAME)

$(TOOL_NAME): $(TOOL_SRC)
	clang -o $(TOOL_NAME) $(TOOL_SRC) `gnustep-config --objc-flags` `gnustep-config --base-libs` -Wl,-rpath,/System/Library/Libraries/

# Install target
install: $(TOOL_NAME)
	@echo "Installing $(TOOL_NAME) to $(INSTALL_DIR)"
	install -d $(INSTALL_DIR)
	install -m 755 $(TOOL_NAME) $(TOOL_INSTALL_DIR)

# Clean target to remove build artifacts
clean:
	@echo "Cleaning up..."
	rm -f $(TOOL_NAME)
	rm -f $(TOOL_NAME) $(TOOL_NAME).d

.PHONY: all install clean
