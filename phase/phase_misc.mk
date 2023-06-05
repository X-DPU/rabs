
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
info: subl_project
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/git
	mkdir -p $(BUILD_DIR)/report
	@echo  $(BINARY_CONTAINERS)
	@echo  $(MK_PATH)
	@echo  "#####################################################################"
	@echo  -e  ${BLUE}$(APP)${NC}
	@echo  "cfg file:"
	@echo  -e  ${RED}$(CFG_FILE)${NC}
	@echo  "kernels:"
	@echo  -e  ${RED}$(KERNEL_OBJS)${NC}
	@echo  "host objects:"
	@echo  -e  ${RED}$(HOST_OBJS)${NC}
	@echo  "global vpp flags:"
	@echo  -e  ${RED}$(VPP_FLAGS)${NC}
	@echo  "global cpp flags:"
	@echo  -e  ${RED}$(CPP_FLAGS)${NC}
	@echo  "#####################################################################"
	git status > ${BUILD_DIR}/git/git_status.log
	git diff > ${BUILD_DIR}/git/code_diff.diff
	git diff --cached > ${BUILD_DIR}/git/code_cached.diff
	git log --graph  -10 > ${BUILD_DIR}/git/git_log.log
	git show HEAD > ${BUILD_DIR}/git/git_show.diff


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

emconfig:$(EMCONFIG_DIR)/emconfig.json
$(EMCONFIG_DIR)/emconfig.json:
	emconfigutil --platform $(DEVICE) --od $(EMCONFIG_DIR)





.PHONY: all host

all:
	$(MAKE) info
	$(MAKE) connect_info
	$(MAKE) check-devices $(EXECUTABLE) $(BINARY_CONTAINERS)
	$(MAKE) emconfig
	$(MAKE) post_compile




############################## Cleaning Rules ##############################

.PHONY: clean cleanall cleanfpga cleanhost

clean:
	-$(RMDIR) $(EXECUTABLE) $(XCLBIN)/{*sw_emu*,*hw_emu*}
	-$(RMDIR) profile_* TempConfig system_estimate.xtxt *.rpt *.csv
	-$(RMDIR) src/*.ll *v++* .Xil emconfig.json dltmp* xmltmp* *.log *.jou *.wcfg *.wdb
	-$(RMDIR) .run
	-$(RMDIR) *.app
	-$(RMDIR) *.protoinst

cleanall: clean
	-$(RMDIR) build_dir* sd_card*
	-$(RMDIR) package*
	-$(RMDIR) _x* *xclbin.run_summary qemu-memory-_* emulation _vimage pl* start_simulation.sh *.xclbin
	-$(RMDIR) fast_build
cleanfpga:
	-$(RMDIR) build_dir*



cleanobj:
	-$(RMDIR) $(EXECUTABLE)
	-$(RMDIR) $(HOST_OBJS)



ifeq (hostemu,$(firstword $(MAKECMDGOALS)))
# use the rest as arguments for "run"
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(RUN_ARGS):;@:)
endif


prog: # ...
    # ...

.PHONY: hostemu
hostemu: cleanhost prog
	${ECHO} args: $(RUN_ARGS)
	kill $(shell pidof xsim) | true
	XCL_EMULATION_MODE=hw_emu  catchsegv ./$(EXECUTABLE)  -fpga ${BUILD_DIR}/kernel.xclbin -qsize 512 $(RUN_ARGS)



.PHONY: automation
automation:
	$(shell ./src/automation.sh > generator.log)


.PHONY: reset
reset:
	(sleep  1 &&  echo -e -n "y\n\n") | xbutil reset
	echo "done"

PROJECT_FILE=${APP}.sublime-project



.PHONY: subl_project
subl_project:
	@echo ${PROJECT_OBJS}
	./mk/script/create_subl_project.sh ${APP} ${PROJECT_OBJS}