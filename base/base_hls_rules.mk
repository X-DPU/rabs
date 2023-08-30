
APP_DIR = $(subdir)

APP_SRC = $(wildcard $(UPPER_DIR)/$(APP_DIR)/*.cpp)
APP_SRC_RMDIR = $(patsubst $(UPPER_DIR)/$(APP_DIR)/%, %,$(APP_SRC))
APP_OBJS = $(patsubst %.cpp, %,$(APP_SRC_RMDIR))
APP_BINARY_CONTAINERS = $(patsubst %, $(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/%.xo,$(APP_OBJS))

BINARY_CONTAINER_OBJS += $(APP_BINARY_CONTAINERS)
KERNEL_OBJS += $(APP_OBJS)

GENERATED_KERNEL_OBJS += $(APP_BINARY_CONTAINERS)

VPP_FLAGS +=  -I $(UPPER_DIR)/$(APP_DIR)
CPP_FLAGS +=  -I $(UPPER_DIR)/$(APP_DIR)

PROJECT_OBJS += $(UPPER_DIR)/$(APP_DIR)


SET_APP_DIR = $(eval COMPILE_APP_DIR=$(dir $<))
SET_KERNEL_NAME = $(eval KERNEL_NAME=$(patsubst $(dir $<)%.cpp,%, $<))
SET_LOCAL_CONFIG_FILE = $(eval LOCAL_CONFIG_FILE=$(patsubst %.cpp,%.ini, $<))



$(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/%.xo: $(UPPER_DIR)/$(APP_DIR)/%.cpp
	$(SET_APP_DIR)
	$(SET_KERNEL_NAME)
	$(SET_LOCAL_CONFIG_FILE)
	$(SET_TMP_LOCAL_CONFIG_FILE)

	@[ -e ${LOCAL_CONFIG_FILE} ] && { \
		echo found local config file ; \
	} || { \
	 	echo no local config file ; \
	}

	@${ECHO}  ${BLUE}$(KERNEL_NAME) in $(COMPILE_APP_DIR)${NC}
	mkdir -p $(TEMP_DIR)/$(COMPILE_APP_DIR)

	@[ -e ${LOCAL_CONFIG_FILE} ] && { \
		faketime '2021-01-01 00:00:00' $(VPP) --config ${LOCAL_CONFIG_FILE} $(VPP_FLAGS)  -c -k $(KERNEL_NAME) --temp_dir $(TEMP_DIR)/$(COMPILE_APP_DIR)  -I '$(<D)' -o'$@' '$<' ;\
	} || { \
		faketime '2021-01-01 00:00:00' $(VPP) $(VPP_FLAGS) -c -k $(KERNEL_NAME) --temp_dir $(TEMP_DIR)/$(COMPILE_APP_DIR)  -I '$(<D)' -o'$@' '$<' ;\
	}
	echo "$(COMPILE_APP_DIR)$(KERNEL_NAME)" > $(BUILD_DIR)/log_path/$(KERNEL_NAME)

%.log: $(UPPER_DIR)/$(APP_DIR)/%.cpp
	$(SET_KERNEL_NAME)
	${EDITOR} $(TEMP_DIR)/$(shell cat $(BUILD_DIR)/log_path/${KERNEL_NAME})/${KERNEL_NAME}/vitis_hls.log





unexport LOCAL_CONFIG_FILE


unexport APP_SRC
unexport APP_OBJS
unexport APP_DIR
unexport APP_SRC_RMDIR
unexport APP_BINARY_CONTAINERS

