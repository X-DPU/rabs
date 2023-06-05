#!/bin/bash

app=$1

shift

project_file=${app}.sublime-project
echo "{\"folders\":[" > ${project_file}
for var in ${1+"$@"}
do
    echo "{\"path\": \"${var}\", \"name\": \"${var}\",},">> ${project_file}
done

echo "],}" >> ${project_file}


exit

#project_suffix = ,},
#project_prefix =
#
#
#echo  $(addsuffix \"${project_suffix} ,  $(addprefix {\"path\":\"${project_prefix},${PROJECT_OBJS}))
#echo ${PROJECT_OBJS}
#echo "{"> ${PROJECT_FILE}
#echo "    \"folders\":">> ${PROJECT_FILE}
#echo "    [">> ${PROJECT_FILE}
#echo "        {">> ${PROJECT_FILE}
#echo "            \"file_exclude_patterns\":">> ${PROJECT_FILE}
#echo "            [">> ${PROJECT_FILE}
#echo "                \"*.log*\",">> ${PROJECT_FILE}
#echo "                \"commented.tex*\",">> ${PROJECT_FILE}
#echo "                \"*.csv\",">> ${PROJECT_FILE}
#echo "                \"*.protoinst\",">> ${PROJECT_FILE}
#echo "                \"*.wcfg\",">> ${PROJECT_FILE}
#echo "                \"*.wdb\",">> ${PROJECT_FILE}
#echo "                \"*.run_summary\",">> ${PROJECT_FILE}
#echo "                \"*.app\",">> ${PROJECT_FILE}
#echo "                \"package_*\",">> ${PROJECT_FILE}
#echo "">> ${PROJECT_FILE}
#echo "            ],">> ${PROJECT_FILE}
#echo "            \"folder_exclude_patterns\":">> ${PROJECT_FILE}
#echo "            [">> ${PROJECT_FILE}
#echo "                \"_x*\",">> ${PROJECT_FILE}
#echo "                \"*.run\",">> ${PROJECT_FILE}
#echo "                \"*.Xil\",">> ${PROJECT_FILE}
#echo "                \"*_x.*\",">> ${PROJECT_FILE}
#echo "                \"*build_dir*\",">> ${PROJECT_FILE}
#echo "            ],">> ${PROJECT_FILE}
#echo "            \"path\":\".\" ,">> ${PROJECT_FILE}
#echo "        },">> ${PROJECT_FILE}
#echo  $(addsuffix \"${project_suffix} ,  $(addprefix \{\"path\":\"${project_prefix},${PROJECT_OBJS})) >> ${PROJECT_FILE}
#echo "    ],">> ${PROJECT_FILE}
#echo "}">> ${PROJECT_FILE}#