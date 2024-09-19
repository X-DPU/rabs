
APP_DIR = $(subdir)

ARM_CPP_SRCS = $(wildcard $(UPPER_DIR)/$(APP_DIR)/*.cpp)
ARM_CPP_APP_SRC_RMDIR = $(patsubst $(UPPER_DIR)/$(APP_DIR)/%, %,$(ARM_CPP_SRCS))

ARM_SRC_OBJS = $(patsubst %.cpp, %,$(ARM_CPP_APP_SRC_RMDIR))


ARM_C_SRCS = $(wildcard $(UPPER_DIR)/$(APP_DIR)/*.c)
ARM_C_APP_SRC_RMDIR = $(patsubst $(UPPER_DIR)/$(APP_DIR)/%, %,$(ARM_C_SRCS))

ARM_SRC_OBJS += $(patsubst %.c, %,$(ARM_C_APP_SRC_RMDIR))



ARM_APP_BINARY_CONTAINERS = $(patsubst %, $(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/%.o,$(ARM_SRC_OBJS))

ARM_OBJS += $(ARM_APP_BINARY_CONTAINERS)

PROJECT_OBJS += $(UPPER_DIR)/$(APP_DIR)

ARM_CPP_FLAGS +=  -I $(UPPER_DIR)/$(APP_DIR)


SET_APP_DIR = $(eval COMPILE_APP_DIR=$(dir $<))
#SET_SRC = $(eval KERNEL_NAME=$(patsubst src/$(COMPILE_APP_DIR)/%.cpp,%, $<))

# $<: Refers to the first prerequisite (the first dependency) of the rule.
# $^: Refers to all the prerequisites (dependencies) of the rule, with duplicates removed. It’s a list of all files that the target depends on.

$(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/%.o: $(UPPER_DIR)/$(APP_DIR)/%.cpp
	$(SET_APP_DIR)
	@${ECHO} ${current_dir}
	@${ECHO} ${PURPLE}$<${NC}
	@${ECHO} "build for ps cpp "$<
	@${ECHO} ${ARM_CXX}
	mkdir -p $(TEMP_DIR)/$(COMPILE_APP_DIR)
	@$(ARM_CXX) $(ARM_CPP_FLAGS)  -o $@ -c $<

$(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/%.o: $(UPPER_DIR)/$(APP_DIR)/%.c
	$(SET_APP_DIR)
	@${ECHO}  ${PURPLE}$<${NC}
	@${ECHO} "build for ps c "$<
	mkdir -p $(TEMP_DIR)/$(COMPILE_APP_DIR)
	@$(ARM_CXX) $(ARM_CPP_FLAGS)  -o $@ -c $<


unexport SRC_OBJS
unexport APP_SRC
unexport APP_DIR
unexport APP_SRC_RMDIR
unexport APP_BINARY_CONTAINERS

