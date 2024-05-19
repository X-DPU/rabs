

if [ $# -lt 1 ];
then
    echo "need a log name "
    exit -1
fi

source utils/highlight.sh

grep -E 'ERROR|WARNING|CRITICAL' $1 | highlight red "ERROR" | highlight yellow "CRITICAL\ WARNING" |  highlight blue  "WARNING:"