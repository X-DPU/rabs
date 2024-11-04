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
clean_arm_obj:
	${RM} $(ARM_OBJS)


rebuild_arm: info
	$(MAKE) clean_arm_obj
	$(MAKE) arm  -j
	${ECHO} "build arm"
