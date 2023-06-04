############################## Help Section ##############################
.PHONY: help

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make app=<app name> all TARGET=<sw_emu/hw_emu/hw>"


include mk/misc/color.mk



.PHONY: info
info:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/git
	mkdir -p $(BUILD_DIR)/report
	@echo  $(BINARY_CONTAINERS)
	@echo  $(MK_PATH)
	@echo  "#####################################################################"
	@echo  -e  ${BLUE}$(APP)${NC}
	@echo  "cfg file:"
	@echo  -e  ${RED}$(CFG_FILE)${NC}
	@echo  "kernels:"
	@echo  -e  ${RED}$(KERNEL_OBJS)${NC}
	@echo  "host objects:"
	@echo  -e  ${RED}$(ALL_OBJECTS)${NC}
	@echo  "global vpp flags:"
	@echo  -e  ${RED}$(VPP_FLAGS)${NC}
	@echo  "global cpp flags:"
	@echo  -e  ${RED}$(CPP_FLAGS)${NC}
	@echo  "#####################################################################"
	git status > ${BUILD_DIR}/git/git_status.log
	git diff > ${BUILD_DIR}/git/code_diff.diff
	git diff --cached > ${BUILD_DIR}/git/code_cached.diff
	git log --graph  -10 > ${BUILD_DIR}/git/git_log.log
	git show HEAD > ${BUILD_DIR}/git/git_show.diff

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





BINARY_CONTAINER_OBJS :=
AIE_CONTAINER_OBJS :=
ALL_OBJECTS :=
KERNEL_OBJS :=

CPP_FLAGS :=
CPP_LDFLAGS  :=

VPP_FLAGS :=
VPP_LDFLAGS :=

AIE_FLAGS :=
AIE_LDFLAGS  :=


POST_COMPILE_SCRIPT = post_compile.sh


HOST_ARCH := x86
SYSROOT :=


EMCONFIG_DIR = $(TEMP_DIR)
BINARY_CONTAINERS += $(BUILD_DIR)/kernel.xclbin

PACKAGE_OUT = ./package_$(APP).$(TARGET)

#TARGET :=



