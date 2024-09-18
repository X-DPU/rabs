ARM_CXX			:= aarch64-linux-gnu-g++
ARM_CPP_FLAGS	+=  -D__PS_ENABLE_AIE__ -Wall
ARM_SYSROOT		?= ../release/sysroots/cortexa72-cortexa53-xilinx-linux/

XRT_INCLUDE     := $(ARM_SYSROOT)/usr/include/xrt
AIE_LINKER      := $(ARM_SYSROOT)/lib


ARM_CPP_FLAGS  += -I$(XILINX_VITIS)/aietools/include/ -I$(XRT_INCLUDE) -I./ -I./kernels
ARM_LDDIRS		:= --sysroot=$(ARM_SYSROOT) -L$(XILINX_VITIS)/aietools/lib/aarch64.o -L$(AIE_LINKER)
ARM_LDLIBS		:= -lxaiengine -ladf_api_xrt -lxrt_core -lxrt_coreutil
ARM_LDFLAGS		:= $(ARM_LDDIRS) $(ARM_LDLIBS)


__PS_SET__ = true


#	$(ARM_CXX) $(ARM_CPP_FLAGS) $^ $(ARM_LDFLAGS) -o $@