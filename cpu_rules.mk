
mkfile_path := $(abspath $(lastword $(filter-out $(lastword $(MAKEFILE_LIST)), $(MAKEFILE_LIST))))
subdir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

temp_dir:=   $(dir  $(patsubst %/,%, $(dir $(mkfile_path))))
upperdir := $(notdir $(patsubst %/,%,$(dir $(temp_dir))))

UPPER_DIR := $(upperdir)


include  mk/base/base_cpu_rules.mk

__PS_SET__ = true
__HOST_SET__ = true

#this is rule for code that can be used both on x86 host and arm side

unexport subdir
unexport temp_dir
unexport upperdir
unexport UPPER_DIR