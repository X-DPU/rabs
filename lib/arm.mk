CXX:= aarch64-linux-gnu-g++
CPP_FLAGS	+=  -D__PS_ENABLE_AIE__ -Wall
ARM_SYSROOT		?= ../../../release/sysroots/cortexa72-cortexa53-xilinx-linux/

XRT_INCLUDE     := $(ARM_SYSROOT)/usr/include/xrt
AIE_LINKER      := $(ARM_SYSROOT)/lib


CPP_FLAGS  += -I$(XILINX_VITIS)/aietools/include/ -I$(XRT_INCLUDE) -I./ -I./kernels --sysroot=$(ARM_SYSROOT)
ARM_LDDIRS		:=  -L$(XILINX_VITIS)/aietools/lib/aarch64.o -L$(AIE_LINKER)
ARM_LDLIBS		:=
CPP_LDFLAGS		:= $(ARM_LDDIRS) $(ARM_LDLIBS)

CXX:= aarch64-linux-gnu-g++


#	$(ARM_CXX) $(ARM_CPP_FLAGS) $^ $(ARM_LDFLAGS) -o $@