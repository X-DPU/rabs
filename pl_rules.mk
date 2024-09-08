
mkfile_path := $(abspath $(lastword $(filter-out $(lastword $(MAKEFILE_LIST)), $(MAKEFILE_LIST))))
subdir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

temp_dir:=   $(dir  $(patsubst %/,%, $(dir $(mkfile_path))))
upperdir := $(notdir $(patsubst %/,%,$(dir $(temp_dir))))

UPPER_DIR := $(upperdir)



ifdef __ADVANCED_HLS__
include  mk/base/base_vivado_hls_rules.mk
else
include  mk/base/base_hls_rules.mk
endif


include  mk/base/base_rtl_rules.mk

__PL_SET__ = true

unexport subdir
unexport temp_dir
unexport upperdir
unexport UPPER_DIR