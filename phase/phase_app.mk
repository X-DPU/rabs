APP :=  $(basename $(app:app/%=%))
APP :=  $(basename $(APP:%/=%))


FREQ := 300

EXECUTABLE := $(APP).app
BUILD_DIR := ./build_dir_$(APP)
TEMP_DIR := ./_x_$(APP)

DEFAULT_CFG  = app/$(APP)/kernel.cfg

PROJECT_OBJS +=  app/$(APP)


VPP_FLAGS := --log_dir ${BUILD_DIR}
VPP_FLAGS += --report_dir ${BUILD_DIR}

BINARY_CONTAINERS = $(BUILD_DIR)/kernel.xclbin

EMCONFIG_DIR = $(TEMP_DIR)
PACKAGE_OUT = $(TEMP_DIR)/package_$(APP).$(TARGET)

include app/$(APP)/kernel.mk

CFG_FILE ?= app/$(APP)/kernel.cfg