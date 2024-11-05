
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


#$(BUILD_DIR)/aie_xrt_kernel.xclbin : $(BUILD_DIR)/aie_kernel.xclbin
#	./mk/script/aie_xclbin_gen.sh $(BUILD_DIR)/aie_kernel.xclbin  $(BUILD_DIR)  $(BUILD_DIR)/aie_xrt_kernel.xclbin


.PHONY: $(BUILD_DIR)/${APP}_aie_ctrl.app
$(BUILD_DIR)/${APP}_aie_ctrl.app:
	@${ECHO} ${RED} "start compile arm program for aie control" ${NC}
	@${RM} $(BUILD_DIR)/${APP}_aie_ctrl.app
	$(ARM_CXX) $(ARM_CPP_FLAGS) ${AIE_PS_SRC} $(ARM_LDFLAGS) -o $@

.PHONY: aie_aie_ctrl
aie_aie_ctrl: $(BUILD_DIR)/${APP}_aie_ctrl.app
	@${ECHO} ${RED} "build aie ctrl application:" $(AIE_PS_APP) ${NC}
	@${CP} $(BUILD_DIR)/${APP}_aie_ctrl.app  ${APP}_aie_aie_ctrl.app





.PHONY: aie_ps
aie_ps: $(AIE_PS_APP)
	@${ECHO} ${RED} "build ps application:" $(AIE_PS_APP) ${NC}
	@${CP} $(AIE_PS_APP)  ${APP}_ps.app


.PHONY: aie_all
aie_all: 	aie_xclbin aie_ps

#	./mk/script/aie_xclbin_gen.sh $(BUILD_DIR)/aie_kernel.xclbin  $(BUILD_DIR)  $(BUILD_DIR)/aie_xrt_kernel.xclbin



aie_clean:
	@${RM}  -rf $(BUILD_DIR)/aie_kernel.xclbin
	@${RM}  -rf $(AIE_CONTAINER_OBJS)
	@${ECHO} $(TEMP_DIR)
	@${ECHO} $(subst $(TEMP_DIR),., ./$(dir $<))
	@${RM}  -rf $(subst $(TEMP_DIR),., ./$(dir $<))/.Xil
	@${RM}  -rf $(subst $(TEMP_DIR),., ./$(dir $<))/Work
	@${RM}  -rf $(subst $(TEMP_DIR),., ./$(dir $<))/*.log
	@${RM}  -rf $(subst $(TEMP_DIR),., ./$(dir $<))/libadf.a


aie_ps_clean:
	@${RM} $(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/${APP}_ps.app
	@${RM} ${APP}_ps.app