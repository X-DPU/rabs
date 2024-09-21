############################## Setting up Host Variables ##############################
#Include Required Host Source Files

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


$(APP).arm.app:  $(ARM_OBJS)
	@${ECHO} ${LIGHT_BLUE}"arm start linking files"${NC}
	@${ECHO} $(ARM_CXX)
	@${ECHO} $(ARM_LDFLAGS)
	@$(ARM_CXX)   $(ARM_CPP_FLAGS) $(ARM_LDFLAGS) $(ARM_OBJS) -Xlinker -o$@ $(ARM_LDFLAGS)
	@cp $(APP).arm.app  ${BUILD_DIR}/$(APP).arm.app
	@${ECHO}  ${LIGHT_BLUE}"arm build done"${NC}


arm:  info  $(APP).arm.app
	@${ECHO} ${AIE_PS_APP}
	$(MAKE) post_compile

rebuild_host: info
	$(MAKE) clean_host_obj
	$(MAKE) $(EXECUTABLE)  -j
	${ECHO} "build a clean host"



.PHONY: aie_obj
aie_obj: $(AIE_CONTAINER_OBJS)
	@${ECHO} "build all aie object:" $(AIE_CONTAINER_OBJS)

.PHONY: aie_xclbin
aie_xclbin: $(BUILD_DIR)/aie_kernel.xclbin
	@${ECHO} "build all aie object:" $(AIE_CONTAINER_OBJS)
	@cp $(BUILD_DIR)/aie_kernel.xclbin  ${APP}_aie_kernel.xclbin

$(BUILD_DIR)/aie_kernel.xclbin : $(AIE_CONTAINER_OBJS)
	$(VPP) -s -p -t $(TARGET) -f $(DEVICE) --package.out_dir ./	\
	       --package.defer_aie_run --config mk/misc/aie_xrt.ini -o $@ $<
	./mk/script/aie_xclbin_gen.sh $(BUILD_DIR)/aie_kernel.xclbin  $(BUILD_DIR)  $(BUILD_DIR)/aie_xrt_kernel.xclbin

.PHONY: aie_xsa
aie_xsa: $(BUILD_DIR)/kernel.xsa


aie_clean: ${AIE_CONTAINER_OBJS}
	@rm  -rf $(BUILD_DIR)/aie_kernel.xclbin
	@rm  -rf $(AIE_CONTAINER_OBJS)
	@${ECHO} $(TEMP_DIR)
	@${ECHO} $(subst $(TEMP_DIR),., ./$(dir $<))
	@rm  -rf $(subst $(TEMP_DIR),., ./$(dir $<))/.Xil
	@rm  -rf $(subst $(TEMP_DIR),., ./$(dir $<))/Work
	@rm  -rf $(subst $(TEMP_DIR),., ./$(dir $<))/*.log
	@rm  -rf $(subst $(TEMP_DIR),., ./$(dir $<))/libadf.a

.PHONY: aie_ps
aie_ps: $(AIE_PS_APP)
	@${ECHO} "build ps application:" $(AIE_PS_APP)
	@cp $(AIE_PS_APP)  ${APP}_ps.app


.PHONY: aie_all
aie_all: 	aie_xclbin aie_ps
