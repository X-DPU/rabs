

include mk/misc/color.mk





############################## Setting up Project Variables ##############################
# Points to top directory of Git repository
MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
COMMON_REPO ?= $(shell bash -c 'export MK_PATH=$(MK_PATH); echo  $${MK_PATH%fpga/*}')
PWD = $(shell readlink -f .)

__PL_SET__ := false
__AIE_SET__ := false
__HOST_SET__ := false

CP = cp -rf
ECHO = echo -e
RM = rm -f
RMDIR = rm -rf


VPP := v++



CPP_FLAGS :=
CPP_LDFLAGS  :=

VPP_FLAGS :=
VPP_LDFLAGS :=

AIE_FLAGS :=
AIE_LDFLAGS  :=


BINARY_CONTAINER_OBJS :=
AIE_CONTAINER_OBJS :=
HOST_OBJS :=

KERNEL_OBJS :=

PROJECT_OBJS := mk


POST_COMPILE_SCRIPT = post_compile.sh


HOST_ARCH := x86
SYSROOT :=


EMCONFIG_DIR = $(TEMP_DIR)
BINARY_CONTAINERS += $(BUILD_DIR)/kernel.xclbin

PACKAGE_OUT = ./package_$(APP).$(TARGET)

#TARGET :=



