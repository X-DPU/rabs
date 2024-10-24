# Host compiler global settings
CPP_FLAGS += -fmessage-length=0
CPP_FLAGS += -I ./src/
CPP_FLAGS += -Wall -O0 -g -rdynamic


CPP_LDFLAGS += -lrt -lstdc++

include mk/lib/opencl.mk


CPP_FLAGS += $(opencl_CPP_FLAGS)
CPP_LDFLAGS += $(opencl_LDFLAGS)



#HOST_OBJS_PATH:=$(addprefix $(TEMP_DIR)/host/,$(SRC_OBJS))
#HOST_OBJS:= $(addsuffix .o, $(HOST_OBJS_PATH))

############################## Setting Rules for Host (Building Host Executable) ##############################
$(EXECUTABLE):  check-xrt | $(HOST_OBJS)
	@${ECHO} ${LIGHT_BLUE}"Host start linking files"${NC}
	@${ECHO} $(CPP_LDFLAGS)
	@$(CXX)   $(CPP_FLAGS) $(CPP_LDFLAGS) $(HOST_OBJS) -Xlinker -o$@ $(CPP_LDFLAGS) $(LIBS)
	@cp $(EXECUTABLE)  ${BUILD_DIR}/$(EXECUTABLE)
	@${ECHO}  ${LIGHT_BLUE}"Host build done"${NC}


host:  info  $(EXECUTABLE)
	$(MAKE) post_compile



rebuild_host: info
	$(MAKE) clean_host_obj
	$(MAKE) $(EXECUTABLE)  -j
	${ECHO} "build a clean host"


