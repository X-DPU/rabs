
include ./mk/misc/utils.mk
XSA :=
ifneq ($(DEVICE), )
XSA := $(call device2xsa, $(DEVICE))
endif



############################## Help Section ##############################
.PHONY: help

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make app=<app name> all TARGET=<sw_emu/hw_emu/hw>"


.PHONY: info
info: gen_subl_project connect_info
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/log_path
	mkdir -p $(BUILD_DIR)/git
	mkdir -p $(BUILD_DIR)/report
	@echo  $(BINARY_CONTAINERS)
	@echo  $(MK_PATH)
	@echo  "#####################################################################"
	@echo  -e  ${BLUE}$(APP)${NC}
	@echo  "cfg file:"
	@echo  -e  ${RED}$(DEFAULT_CFG)${NC}
	@echo  "kernels:"
	@echo  -e  ${RED}$(KERNEL_OBJS)${NC}
	@echo  "host objects:"
	@echo  -e  ${RED}$(HOST_OBJS)${NC}
	@echo  "global vpp flags:"
	@echo  -e  ${RED}$(VPP_FLAGS)${NC}
	@echo  "global vpp ld flags:"
	@echo  -e  ${RED}$(VPP_LDFLAGS)${NC}
	@echo  "global cpp flags:"
	@echo  -e  ${RED}$(CPP_FLAGS)${NC}
	@echo  "#####################################################################"
	git status > ${BUILD_DIR}/git/git_status.log | true
	git diff > ${BUILD_DIR}/git/code_diff.diff | true
	git diff --cached > ${BUILD_DIR}/git/code_cached.diff | true
	git log --graph  -10 > ${BUILD_DIR}/git/git_log.log | true
	git show HEAD > ${BUILD_DIR}/git/git_show.diff | true
	@echo "Using $(NUM_CORES) cores"


.PHONY: emconfig connect_info post_compile

post_compile:
	cp -f ${DEFAULT_CFG}.json.pdf  $(BUILD_DIR)/
	@[ -e ${POST_COMPILE_SCRIPT} ] && { \
		echo found post compile script ; \
		./${POST_COMPILE_SCRIPT} ${BUILD_DIR} ;\
	} || { \
		echo Post compile done; \
	}

connect_info: ${DEFAULT_CFG}
	./mk/script/connect_parser.py  ${DEFAULT_CFG}
	cp -f ${DEFAULT_CFG}.json.pdf /data/connect_info/$(APP)_kernel.pdf | true

project_log:
	${EDITOR}  $(TEMP_DIR)/link/vivado/vpl/runme.log


multi_stage_log:
	${EDITOR} 	$(TEMP_DIR)/link/vivado/vpl/prj/prj.runs/impl_1/runme.log  	\
				$(TEMP_DIR)/link/vivado/vpl/prj/prj.runs/impl_Performance_WLBlockPlacementFanoutOpt/runme.log 	\
	 			$(TEMP_DIR)/link/vivado/vpl/prj/prj.runs/impl_Performance_ExplorePostRoutePhysOpt/runme.log  	\
	 			$(TEMP_DIR)/link/vivado/vpl/prj/prj.runs/impl_Performance_NetDelay_high/runme.log


open_vivado_project:
	vivado $(TEMP_DIR)/link/vivado/vpl/prj/prj.xpr

cat_project_log:
	${CAT}  $(TEMP_DIR)/link/vivado/vpl/runme.log

report: subl_project
	${EDITOR} $(BUILD_DIR)/link/imp/impl_1_full_util_routed.rpt
	${EDITOR} $(BUILD_DIR)/link/imp/impl_1_kernel_util_routed.rpt
	${EDITOR} $(TEMP_DIR)/link/vivado/vpl/runme.log


emconfig:$(EMCONFIG_DIR)/emconfig.json
$(EMCONFIG_DIR)/emconfig.json:
	emconfigutil --platform $(DEVICE) --od $(EMCONFIG_DIR)





.PHONY: all host

all:
	$(MAKE) info
	$(MAKE) connect_info
	$(MAKE) check-devices
	$(MAKE) $(EXECUTABLE) -j
	$(MAKE) $(BINARY_CONTAINERS)
	$(MAKE) emconfig
	$(MAKE) post_compile




############################## Cleaning Rules ##############################

.PHONY: clean cleanall cleanfpga rebuild_host


clean_${APP}:
	-$(RMDIR) hls_proj_${APP}_*
	-$(RMDIR) $(TEMP_DIR)
	-$(RMDIR) $(BUILD_DIR)

clean:
	-$(RMDIR) $(EXECUTABLE) $(XCLBIN)/{*sw_emu*,*hw_emu*}
	-${RMDIR} ${TEMP_DIR}
	-$(RMDIR) profile_* TempConfig system_estimate.xtxt *.rpt *.csv
	-$(RMDIR) src/*.ll *v++* .Xil emconfig.json dltmp* xmltmp* *.log *.jou *.wcfg *.wdb
	-$(RMDIR) .run
	-$(RMDIR) proj_*


cleanall: clean
	-$(RMDIR) build_dir* sd_card*
	-$(RMDIR) package*
	-$(RMDIR) _x* *xclbin.run_summary qemu-memory-_* emulation _vimage pl* start_simulation.sh *.xclbin
	-$(RMDIR) fast_build
	-$(RMDIR) *.sublime-project
	-$(RMDIR) *.sublime-workspace
	-$(RMDIR) *.app
	-$(RMDIR) *.protoinst
	-$(RMDIR) hls_proj_*

clean_fpga_obj: clean_fpga_bit
	-$(RMDIR) $(GENERATED_KERNEL_OBJS)
	-$(RMDIR) .run

clean_fpga_bit:
	-$(RMDIR) $(BUILD_DIR)

clean_host_obj:
	-$(RMDIR) $(EXECUTABLE)
	-$(RMDIR) $(HOST_OBJS)



.PHONY: run_hw_emu
run_hw_emu:
	$(MAKE) clean_host_obj
	$(MAKE) $(EXECUTABLE) TARGET=hw_emu  -j
	${ECHO} args: $(RUN_ARGS)
	kill $(shell pgrep xsim) | true
	kill $(shell pgrep xsimk) | true
	XCL_EMULATION_MODE=hw_emu  ./$(EXECUTABLE) $(EMU_ARGS)




run_hw_emu_backtrace:
	$(MAKE) clean_host_obj
	$(MAKE) $(EXECUTABLE) TARGET=hw_emu  -j
	${ECHO} args: $(RUN_ARGS)
	kill $(shell pgrep xsim) | true
	kill $(shell pgrep xsimk) | true
	XCL_EMULATION_MODE=hw_emu  catchsegv ./$(EXECUTABLE) $(EMU_ARGS)

rerun_hw_emu:
	$(MAKE) clean_fpga_obj -j
	$(MAKE) TARGET=hw_emu all  -j
	$(MAKE) TARGET=hw_emu run_hw_emu  -j


.PHONY: automation
automation:
	$(shell ./src/automation.sh > generator.log)


.PHONY: reset
reset:
	(sleep  1 &&  echo -e -n "y\n\n") | xbutil reset
	echo "done"

PROJECT_FILE=${APP}.sublime-project


.PHONY: gen_subl_project
gen_subl_project:
	@echo ${PROJECT_OBJS}
	./mk/script/create_subl_project.sh ${APP} ${PROJECT_OBJS}


.PHONY: subl_project
subl_project: gen_subl_project
	wmctrl -s 0 && subl ${APP}.sublime-project

.PHONY: display_topo
display_topo: connect_info
	nautilus -w  ${FULL_APP_PATH}  &



.PHONY: bd_topo
bd_topo:
	vivado -mode batch -source mk/tcl/save_bd.tcl -tclargs  ${TEMP_DIR}