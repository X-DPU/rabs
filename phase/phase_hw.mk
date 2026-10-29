############################## Setting up Kernel Variables ##############################
# Kernel compiler global settings
VPP_FLAGS += -t $(TARGET) --platform $(DEVICE) --save-temps --verbose
ifneq ($(TARGET), hw)
	VPP_FLAGS += -g
endif

VPP_FLAGS += -I ./src/ --vivado.param general.maxThreads=${NUM_CORES} --vivado.synth.jobs ${NUM_CORES}
VPP_FLAGS += --remote_ip_cache  ./.rabs_ipcache

# Kernel linker flags
ifdef __ADVANCED_HLS__
	# adhoc support for fixed clock
	# VPP_LDFLAGS += --clock.defaultFreqHz $(FREQ)
else
	VPP_LDFLAGS += --kernel_frequency $(FREQ)
endif

VPP_LDFLAGS += --vivado.param general.maxThreads=${NUM_CORES}  --vivado.impl.jobs ${NUM_CORES} --vivado.param noc.enableCompilerHiEffort=1 --vivado.param place.preplaceNoC=1 --config ${DEFAULT_CFG}
# ARM-side (M_AXI_FPD) address for every kernel control slave, assigned before v++'s own
# auto assignment, which leaves the 64 KB ones host-only since the host reaches the control
# interconnect too (see mk/script/arm_cu_addr.tcl)
VPP_LDFLAGS += --advanced.param compiler.userPostSysLinkOverlayTcl=$(abspath mk/script/arm_cu_addr.tcl)



.PHONY: xo
xo: $(BINARY_CONTAINER_OBJS)
	@${ECHO} "build all xo:" $(BINARY_CONTAINER_OBJS)


$(BUILD_DIR)/kernel.xsa: $(BINARY_CONTAINER_OBJS) $(AIE_CONTAINER_OBJS)
	$(VPP) $(VPP_FLAGS) -l $(VPP_LDFLAGS) --temp_dir $(TEMP_DIR)  -o'$(BUILD_DIR)/kernel.xsa' $(BINARY_CONTAINER_OBJS) $(AIE_CONTAINER_OBJS)





.PHONY: package_from_xsa
package_from_xsa: $(BUILD_DIR)/opendpu_kernel.xclbin


$(BUILD_DIR)/opendpu_kernel.xclbin:  $(BUILD_DIR)/kernel.xsa
	@${ECHO} $(BINARY_CONTAINER_OBJS)
	$(VPP) -p $(BUILD_DIR)/kernel.xsa $(AIE_CONTAINER_OBJS) --temp_dir $(TEMP_DIR)  -t $(TARGET) --platform $(DEVICE) -o $(BUILD_DIR)/opendpu_kernel.xclbin  --package.out_dir $(PACKAGE_OUT)  --package.boot_mode=ospi
	./mk/script/extract_xclbin.sh  $(BUILD_DIR)/opendpu_kernel.xclbin  $(BUILD_DIR)

$(BUILD_DIR)/ip_layout.json:  $(BUILD_DIR)/opendpu_kernel.xclbin
	./mk/script/extract_xclbin.sh  $(BUILD_DIR)/opendpu_kernel.xclbin  $(BUILD_DIR)

.PHONY: extract_base_address
extract_base_address: $(APP_PATH)/$(APP)/opendpu_base_address.h  $(APP_PATH)/$(APP)/kernel_table.h $(APP_PATH)/$(APP)/opendpu_app_host_map.h

# host (PCIe BAR2) view of the app's CUs, for the host driver (RDMA endpoint since the
# stack left the shell); also dropped into release/ where driver/Makefile already looks.
.PHONY: $(APP_PATH)/$(APP)/opendpu_app_host_map.h
$(APP_PATH)/$(APP)/opendpu_app_host_map.h: $(BUILD_DIR)/kernel.xsa
	./mk/script/host_map.py $(BUILD_DIR)/kernel.xsa $(BUILD_DIR)/opendpu_app_host_map.h
	cp $(BUILD_DIR)/opendpu_app_host_map.h $(APP_PATH)/$(APP)/opendpu_app_host_map.h
	mkdir -p ../release && cp $(BUILD_DIR)/opendpu_app_host_map.h ../release/opendpu_app_host_map.h


.PHONY: $(APP_PATH)/$(APP)/opendpu_base_address.h
$(APP_PATH)/$(APP)/opendpu_base_address.h: $(BUILD_DIR)/ip_layout.json $(BUILD_DIR)/kernel.xsa
	echo ${APP_PATH}/$(APP)
	./mk/script/base_address.py --xsa $(BUILD_DIR)/kernel.xsa $(BUILD_DIR)/ip_layout.json  $(BUILD_DIR)/opendpu_base_address.h
	cp  $(BUILD_DIR)/opendpu_base_address.h $(APP_PATH)/$(APP)/opendpu_base_address.h


.PHONY: $(APP_PATH)/$(APP)/kernel_table.h
# ARM (M_AXI_FPD) view of the CUs, taken from the hand-off -- ip_layout.json holds the host
# view now that the PCIe host reaches the control interconnect too (doc/secure-shell.md 6.4)
$(APP_PATH)/$(APP)/kernel_table.h: $(BUILD_DIR)/ip_layout.json $(BUILD_DIR)/kernel.xsa
	./mk/script/kernel_table.py --xsa $(BUILD_DIR)/kernel.xsa $(BUILD_DIR)/ip_layout.json $(BUILD_DIR)/kernel_table.h
	cp $(BUILD_DIR)/kernel_table.h $(APP_PATH)/$(APP)/kernel_table.h

.PHONY: xsa_bitstream
xsa_bitstream: $(BUILD_DIR)/kernel.xsa


############################## Setting Rules for Binary Containers (Building Kernels) ##############################
$(BUILD_DIR)/kernel.xclbin:  $(BINARY_CONTAINER_OBJS) $(AIE_CONTAINER_OBJS)
	@${ECHO} $(BINARY_CONTAINER_OBJS)
ifeq ($(__AIE_SET__), true)
	$(VPP) $(VPP_FLAGS) -l $(VPP_LDFLAGS) --temp_dir $(TEMP_DIR)  -o'$(BUILD_DIR)/kernel.xsa' $(BINARY_CONTAINER_OBJS) $(AIE_CONTAINER_OBJS)
	$(VPP) -p $(BUILD_DIR)/kernel.xsa $(AIE_CONTAINER_OBJS) --temp_dir $(TEMP_DIR)  -t $(TARGET) --platform $(DEVICE) -o $(BUILD_DIR)/kernel.xclbin  --package.out_dir $(PACKAGE_OUT)  --package.boot_mode=ospi

else ifeq ($(__PL_SET__), true)
	$(VPP) $(VPP_FLAGS) -l $(VPP_LDFLAGS) --temp_dir $(TEMP_DIR)  -o'$(BUILD_DIR)/kernel.link.xclbin' $(BINARY_CONTAINER_OBJS)
	$(VPP) -p $(BUILD_DIR)/kernel.link.xclbin --temp_dir $(TEMP_DIR) -t $(TARGET) --platform $(DEVICE) --package.out_dir $(PACKAGE_OUT) -o $(BUILD_DIR)/kernel.xclbin
else

endif

	cp $(TEMP_DIR)/reports/link/imp/impl_1_full_util_routed.rpt    ${BUILD_DIR}/report/  | true
	cp $(TEMP_DIR)/reports/link/imp/impl_1_kernel_util_routed.rpt  ${BUILD_DIR}/report/  | true
	cat $(TEMP_DIR)/link/vivado/vpl/runme.log |  grep scaled\ frequency >   ${BUILD_DIR}/clock.log | true





.PHONY: build
build: check-vitis  $(BINARY_CONTAINERS)

.PHONY: xclbin
xclbin: build


