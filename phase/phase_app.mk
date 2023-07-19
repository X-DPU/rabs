



APP :=  $(basename $(build_app:${APP_PATH}/%=%))
APP :=  $(basename $(APP:%/=%))


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
