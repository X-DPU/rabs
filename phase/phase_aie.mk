
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


.PHONY: $(BUILD_DIR)/${APP}.aie_ctrl.app
$(BUILD_DIR)/${APP}.aie_ctrl.app:
	@${ECHO} ${RED} "start compile arm program for aie control" ${NC}
	@${RM} $(BUILD_DIR)/${APP}.aie_ctrl.app
	$(ARM_CXX) $(ARM_CPP_FLAGS) $(AIE_PS_CPP_FLAGS) ${AIE_PS_SRC} $(ARM_LDFLAGS) $(AIE_PS_LDFLAGS) -o $@

.PHONY: aie_ctrl
aie_ctrl: $(BUILD_DIR)/${APP}.aie_ctrl.app
	@${ECHO} ${RED} "build aie ctrl application:" $(AIE_PS_APP) ${NC}
	@${CP} $(BUILD_DIR)/${APP}.aie_ctrl.app  ${APP}.aie_ctrl.app




.PHONY: aie_all
aie_all: 	aie_xclbin aie_ctrl

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
	@${RM} $(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/${APP}.ps.app
	@${RM} ${APP}.ps.app
# make aie_viz app=<app> [AIE_VIZ_WORK=<Work dir name>]
#   Opens the AIE compile summary of the app's graph in Vitis Analyzer: the graph view (kernels + streams) and the
#   array view (tile placement, stream-switch routing, PLIO shim columns). Needs an X display (ssh -X / VNC); without
#   one it lists the static reports (graph.png / graph.pdf / graph_mapped_post.png) to open elsewhere.
#   AIE_VIZ_WORK picks another compile in the same directory, e.g. AIE_VIZ_WORK=Work_bitstream.
AIE_VIZ_WORK ?= Work
AIE_VIZ_DIRS = $(patsubst $(TEMP_DIR)/%/libadf.a,%,$(AIE_CONTAINER_OBJS))
.PHONY: aie_viz
aie_viz:
	@for d in $(AIE_VIZ_DIRS); do \
	  s=$$d/$(AIE_VIZ_WORK)/graph.aiecompile_summary; \
	  if [ ! -f $$s ]; then echo "no $$s: compile the graph first (make aie_obj app=$(APP))"; continue; fi; \
	  if [ -n "$$DISPLAY" ]; then echo "vitis_analyzer $$s"; vitis_analyzer $$s; \
	  else echo "no DISPLAY: static reports of $$d/$(AIE_VIZ_WORK):"; ls -1 $$d/$(AIE_VIZ_WORK)/reports/*.png $$d/$(AIE_VIZ_WORK)/reports/*.pdf 2>/dev/null; fi; \
	done
