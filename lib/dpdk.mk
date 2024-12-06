

CPP_FLAGS  += $(shell pkg-config --cflags libdpdk)
CPP_LDFLAGS += $(shell pkg-config --libs libdpdk)