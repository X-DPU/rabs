############################## Setting up Host Variables ##############################
#Include Required Host Source Files

# Host compiler global settings
CPP_FLAGS += -fmessage-length=0
CPP_FLAGS += -I ./src/
CPP_LDFLAGS += -lrt -lstdc++ -lxilinxopencl


include mk/lib/opencl.mk

CPP_FLAGS += $(opencl_CPP_FLAGS) -Wall -O0 -g -rdynamic -std=c++11
CPP_LDFLAGS += $(opencl_LDFLAGS)



#ALL_OBJECTS_PATH:=$(addprefix $(TEMP_DIR)/host/,$(SRC_OBJS))
#ALL_OBJECTS:= $(addsuffix .o, $(ALL_OBJECTS_PATH))

############################## Setting Rules for Host (Building Host Executable) ##############################
$(EXECUTABLE):  check-xrt | $(ALL_OBJECTS)
	@${ECHO} ${LIGHT_BLUE}"Start linking files"${NC}
	@${ECHO} $(CPP_LDFLAGS)
	@$(CXX)   $(CPP_FLAGS) $(CPP_LDFLAGS) $(ALL_OBJECTS) -Xlinker -o$@ $(CPP_LDFLAGS) $(LIBS)
	@cp $(EXECUTABLE)  ${BUILD_DIR}/$(EXECUTABLE)
	@${ECHO}  ${LIGHT_BLUE}"Build done"${NC}


