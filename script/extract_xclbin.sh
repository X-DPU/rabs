#!/bin/bash
filename=" "
if [ $# -lt 2 ];
then
    echo "need a xclbin name and output path"
    exit -1
else
    filename=$1
    file_path=$2
fi

 flag=" --dump-section IP_LAYOUT:JSON:${file_path}/ip_layout.json "
flag+=" --dump-section MEM_TOPOLOGY:JSON:${file_path}/mem_topology.json "
flag+=" --dump-section EMBEDDED_METADATA:RAW:${file_path}/embedded_metadata.xml "


xclbinutil --info --input ${filename}


xclbinutil  --force   ${flag} --input ${filename}