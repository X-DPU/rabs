NAME = $(APP_NAME).app
BASE_PATH := ../../fast_build/$(NAME)
BASE_PATH_TMP :=$(BASE_PATH)/prebuild
ECHO_HEADER :="    "
GLOBAL_HEADER :="[TEST] "


OBJS := $(patsubst %.c,%.o,$(wildcard *.c))

OBJS += $(patsubst %.cpp,%.o,$(wildcard *.cpp))


HOST_OBJS:=$(addprefix $(BASE_PATH_TMP)/,$(OBJS))


include ../../mk/base/fast_build_common.mk

CPPFLAGS += $(CPP_FLAGS)
LIBS += $(CPP_LDFLAGS)

all:  $(BASE_PATH)/$(NAME)

prepare:
	@echo $(GLOBAL_HEADER)"prepare for build..."
	@rm -rf $(BASE_PATH)
	@mkdir -p $(BASE_PATH)
	@mkdir -p $(BASE_PATH_TMP)
	@echo "CXX:"
	@echo $(ECHO_HEADER)$(CXX)
	@echo "CFLAGS:"
	@echo $(ECHO_HEADER)$(CFLAGS)
	@echo "CPPFLAGS:"
	@echo $(ECHO_HEADER)$(CPPFLAGS)
	@echo "CPP_LDFLAGS:"
	@echo $(ECHO_HEADER)$(CPP_LDFLAGS)
	@echo "LIBS:"
	@echo $(ECHO_HEADER)$(LIBS)
	@echo $(ECHO_HEADER)

$(BASE_PATH_TMP)/%.o: %.cpp
	@echo $(GLOBAL_HEADER)"build for cpp "$<
	@$(CXX)  $(CFLAGS) $(CPPFLAGS)  -o $@  -c $<
	@$(CXX) $(CFLAGS) $(CPPFLAGS)  -MM -MF  $(patsubst %.o,%.d,$@) $< 
$(BASE_PATH_TMP)/%.o: %.c
	@echo $(GLOBAL_HEADER)"build for c "$<
	@$(CXX)  $(CFLAGS)   -o $@  -c $<
	@$(CXX) $(CFLAGS)   -MM -MF  $(patsubst %.o,%.d,$@) $< 
$(BASE_PATH)/$(NAME): prepare $(HOST_OBJS)
	@echo $(GLOBAL_HEADER)"start link files"
	@$(CXX)   $(CFLAGS) $(CPPFLAGS) $(HOST_OBJS) -Xlinker -o$@ $(CPP_LDFLAGS) $(LIBS)
	@cp  $(BASE_PATH)/$(NAME) $(NAME)
	@echo $(GLOBAL_HEADER)"build done"
clean:
	@echo $(GLOBAL_HEADER)"clean..."
	@rm -rf $(BASE_PATH)
	@echo $(GLOBAL_HEADER)"clean success"
