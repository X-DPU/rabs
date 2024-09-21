#!/bin/bash
if [ $# -lt 1 ];
then
    echo "need a project name "
    exit -1
fi


rm -f ulp.xclbin
project_name=$1
cp ../${project_name}/${project_name}.runs/impl_1/top_i_ulp_my_rm_partial.pdi  .




flag="--add-section BITSTREAM_PARTIAL_PDI:raw:top_i_ulp_my_rm_partial.pdi "
flag+="--add-section IP_LAYOUT:JSON:ip_layout_vecadd.json "
flag+="--add-section MEM_TOPOLOGY:JSON:mem_topology.json "
flag+="--add-section PARTITION_METADATA:JSON:partition_metadata.json "
flag+="--add-section CLOCK_FREQ_TOPOLOGY:JSON:clock_freq_topology.json "
flag+="--add-section EMBEDDED_METADATA:RAW:embedded_metadata_vecadd.xml "

xclbinutil --force --target hw --key-value SYS:dfx_enable:true ${flag}   --key-value SYS:PlatformVBNV:xilinx_vck5000_gen4x8_qdma_2_202220_1 --output ulp.xclbin

xclbinutil --quiet --force --info ulp.xclbin.info --input ulp.xclbin
