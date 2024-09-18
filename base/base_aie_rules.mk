
APP_DIR = $(subdir)


#AIE_FLAG += --platform=/opt/xilinx/platforms/xilinx_vck5000_gen4x8_qdma_2_202220_1/xilinx_vck5000_gen4x8_qdma_2_202220_1.xpfm




AIE_CONTAINER_OBJS += $(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/libadf.a

PROJECT_OBJS += $(UPPER_DIR)/$(APP_DIR)


$(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/ps.app: $(UPPER_DIR)/$(APP_DIR)/src/graph.cpp  $(UPPER_DIR)/$(APP_DIR)/Work/ps/c_rts/aie_control_xrt.cpp
	@${ECHO} ${RED} "start compile arm program" ${NC}
	$(ARM_CXX) $(ARM_CPP_FLAGS) $^ $(ARM_LDFLAGS) -o $@


$(UPPER_DIR)/$(APP_DIR)/Work/ps/c_rts/aie_control_xrt.cpp:  ${AIE_CONTAINER_OBJS}



$(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/libadf.a: $(UPPER_DIR)/$(APP_DIR)/src/*.cpp
	@${ECHO} $(dir $(patsubst %/,%, $(dir $<)))
	make -C ./$(dir $(patsubst %/,%, $(dir $<))) -f ../../mk/base/base_aie_rules.mk  aie_compile AIE_FLAGS="${AIE_FLAGS}" AIE_PLATFORM="${AIE_PLATFORM}"
	mkdir -p $(TEMP_DIR)/$(dir $(patsubst %/,%, $(dir $<)))
	@cp  $(dir $(patsubst %/,%, $(dir $<)))/libadf.a  $@




## reserved for debug
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Clean build products
inner_aie_clean:
	-@rm -rf .Xil .ipcache vivado* *.xpe *.txt *.log
	-@rm -rf Work libadf.a
	-@rm -rf x86simulator_output aiesimulator_output xnwOut .AIE_SIM_CMD_LINE_OPTIONS pl_sample_count* *.html ISS_RPC_SERVER_PORT

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Compile AIE code
aie_compile: libadf.a

libadf.a: src/*
	@echo ${AIE_FLAGS}
	@echo "INFO:- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	@echo "INFO:Running aiecompiler for hw..."
	@rm -rf Work libadf.a
	@mkdir -p Work
	@aiecompiler --target=hw --include="." --platform=${AIE_PLATFORM} --include="src" ${AIE_FLAGS} --workdir=./Work src/graph.cpp

aie_compile_x86:
	@echo "INFO:- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	@echo "INFO:Running aiecompiler for x86sim..."
	@rm -rf Work libadf.a
	@mkdir -p Work
	@aiecompiler --target=x86sim --include="src" --include="../common" --workdir=./Work src/graph.cpp

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulate AIE code
aie_simulate:
	@echo "INFO:- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	@echo "INFO:Running aiesimulator..."
	@aiesimulator --pkg-dir=./Work --profile

aie_simulate_x86:
	@echo "INFO:- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	@echo "INFO:Running x86simulator..."
	@x86simulator --pkg-dir=./Work



unexport APP_SRC
unexport APP_OBJS
unexport APP_DIR
unexport APP_SRC_RMDIR
unexport APP_BINARY_CONTAINERS

