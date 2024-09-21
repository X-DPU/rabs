#!/bin/bash


filename=" "
if [ $# -lt 3 ];
then
    echo "need a xclbin name and input path"
    exit -1
else
    filename=$1
    file_path=$2
    output_file=$3
fi

 flag=" --add-section IP_LAYOUT:JSON:${file_path}/ip_layout.json "
flag+=" --add-section MEM_TOPOLOGY:JSON:${file_path}/mem_topology.json "
flag+=" --add-section EMBEDDED_METADATA:RAW:${file_path}/embedded_metadata.xml "


rm ${output_file}
xclbinutil --force --target hw ${flag}   --input  ${filename}  --output ${output_file}

xclbinutil --quiet --force --info ${output_file}.info --input ${output_file}

