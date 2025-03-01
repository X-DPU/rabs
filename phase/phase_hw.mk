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

VPP_LDFLAGS += --vivado.param general.maxThreads=${NUM_CORES}  --vivado.impl.jobs ${NUM_CORES} --config ${DEFAULT_CFG}



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
extract_base_address: $(APP_PATH)/$(APP)/opendpu_base_address.h  $(APP_PATH)/$(APP)/kernel_table.h


.PHONY: $(APP_PATH)/$(APP)/opendpu_base_address.h
$(APP_PATH)/$(APP)/opendpu_base_address.h: $(BUILD_DIR)/ip_layout.json
	echo ${APP_PATH}/$(APP)
	./mk/script/base_address.py $(BUILD_DIR)/ip_layout.json  $(BUILD_DIR)/opendpu_base_address.h
	cp  $(BUILD_DIR)/opendpu_base_address.h $(APP_PATH)/$(APP)/opendpu_base_address.h


.PHONY: $(APP_PATH)/$(APP)/kernel_table.h
$(APP_PATH)/$(APP)/kernel_table.h: $(BUILD_DIR)/ip_layout.json
	./mk/script/kernel_table.py $(BUILD_DIR)/ip_layout.json $(BUILD_DIR)/kernel_table.h
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


