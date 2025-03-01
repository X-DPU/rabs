
APP_DIR = $(subdir)

CPP_SRCS = $(wildcard $(UPPER_DIR)/$(APP_DIR)/*.cpp)
CPP_APP_SRC_RMDIR = $(patsubst $(UPPER_DIR)/$(APP_DIR)/%, %,$(CPP_SRCS))

SRC_OBJS = $(patsubst %.cpp, %,$(CPP_APP_SRC_RMDIR))


C_SRCS = $(wildcard $(UPPER_DIR)/$(APP_DIR)/*.c)
C_APP_SRC_RMDIR = $(patsubst $(UPPER_DIR)/$(APP_DIR)/%, %,$(C_SRCS))

SRC_OBJS += $(patsubst %.c, %,$(C_APP_SRC_RMDIR))


PROJECT_OBJS += $(UPPER_DIR)/$(APP_DIR)


APP_BINARY_CONTAINERS = $(patsubst %, $(TEMP_DIR)/host/$(UPPER_DIR)/$(APP_DIR)/%.o,$(SRC_OBJS))
HOST_OBJS += $(APP_BINARY_CONTAINERS)
CPP_FLAGS +=  -I $(UPPER_DIR)/$(APP_DIR)


ARM_APP_BINARY_CONTAINERS = $(patsubst %, $(TEMP_DIR)/arm/$(UPPER_DIR)/$(APP_DIR)/%.o,$(SRC_OBJS))
ARM_OBJS += $(ARM_APP_BINARY_CONTAINERS)
ARM_CPP_FLAGS +=  -I $(UPPER_DIR)/$(APP_DIR)



SET_APP_DIR = $(eval COMPILE_APP_DIR=$(dir $<))
#SET_SRC = $(eval KERNEL_NAME=$(patsubst src/$(COMPILE_APP_DIR)/%.cpp,%, $<))

$(TEMP_DIR)/host/$(UPPER_DIR)/$(APP_DIR)/%.o: $(UPPER_DIR)/$(APP_DIR)/%.cpp
	$(SET_APP_DIR)
	@${ECHO} ${current_dir}
	@${ECHO} ${PURPLE}$<${NC}
	@${ECHO} "build for cpp "$<
	mkdir -p $(TEMP_DIR)/host/$(COMPILE_APP_DIR)
	@$(CXX) $(CPP_FLAGS)  -o $@  -c $<
ifeq ($(__HIP_SET__), true)
	@${ECHO} "Disable dependencies generation for HIP compiler"
else
	@$(CXX) $(CPP_FLAGS)  -MM -MF  $(patsubst %.o,%.d,$@) $<
endif

$(TEMP_DIR)/host/$(UPPER_DIR)/$(APP_DIR)/%.o: $(UPPER_DIR)/$(APP_DIR)/%.c
	$(SET_APP_DIR)
	@${ECHO}  ${PURPLE}$<${NC}
	@${ECHO} "build for c "$<
	mkdir -p $(TEMP_DIR)/host/$(COMPILE_APP_DIR)
	@$(CXX) $(CPP_FLAGS)  -o $@  -c $<
ifeq ($(__HIP_SET__), true)
	@${ECHO} "Disable dependencies generation for HIP compiler"
else
	@$(CXX) $(CPP_FLAGS)  -MM -MF  $(patsubst %.o,%.d,$@) $<
endif


$(TEMP_DIR)/arm/$(UPPER_DIR)/$(APP_DIR)/%.o: $(UPPER_DIR)/$(APP_DIR)/%.cpp
	$(SET_APP_DIR)
	@${ECHO} ${current_dir}
	@${ECHO} ${PURPLE}$<${NC}
	@${ECHO} "build for ps cpp "$<
	@${ECHO} ${ARM_CXX}
	mkdir -p $(TEMP_DIR)/arm/$(COMPILE_APP_DIR)
	@$(ARM_CXX) $(ARM_CPP_FLAGS)  -o $@ -c $<

$(TEMP_DIR)/arm/$(UPPER_DIR)/$(APP_DIR)/%.o: $(UPPER_DIR)/$(APP_DIR)/%.c
	$(SET_APP_DIR)
	@${ECHO}  ${PURPLE}$<${NC}
	@${ECHO} "build for ps c "$<
	mkdir -p $(TEMP_DIR)/arm/$(COMPILE_APP_DIR)
	@$(ARM_CXX) $(ARM_CPP_FLAGS)  -o $@ -c $<



unexport SRC_OBJS
unexport APP_SRC
unexport APP_DIR
unexport APP_SRC_RMDIR
unexport APP_BINARY_CONTAINERS

