

app_without_suffix=  $(basename $(app:%/=%))
app_name =  $(notdir ${app_without_suffix})
FULL_APP_PATH = $(shell ./mk/script/find_app.py --input  ${app_name})


APP= $(notdir ${FULL_APP_PATH})
APP_PATH= $(dir ${FULL_APP_PATH})


.PHONY: app_test
app_test:
	echo ${FULL_APP_PATH}

FREQ := 300

EXECUTABLE := $(APP).app
BUILD_DIR := ./build_dir_$(APP)
TEMP_DIR := ./_x_$(APP)

DEFAULT_CFG  := ${APP_PATH}/$(APP)/kernel.cfg

PROJECT_OBJS +=  ${APP_PATH}/$(APP)


VPP_FLAGS := --log_dir ${BUILD_DIR}
VPP_FLAGS += --report_dir ${BUILD_DIR}

BINARY_CONTAINERS = $(BUILD_DIR)/kernel.xclbin

EMCONFIG_DIR = $(TEMP_DIR)
PACKAGE_OUT = $(TEMP_DIR)/package_$(APP).$(TARGET)

include ${APP_PATH}/$(APP)/kernel.mk


ifeq "${TARGET}" "hw_emu"

CPP_FLAGS += -D__EMULATION__
VPP_FLAGS += -D__EMULATION__

#VPP_LDFLAGS += --advanced.param compiler.enableIncrHwEmu=true

endif