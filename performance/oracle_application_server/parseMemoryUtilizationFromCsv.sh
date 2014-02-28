#!/bin/bash

################ Not configurable section 

if [[ $# -ne 2 ]]
then
  echo "`date +'%d/%b/%Y %H:%M:%S'` [Error] Wrong numbers of parameters $#"
  echo "Usage: `basename $0` <gziped_csv_file> <instancePID>" 
  exit 1
fi

zcat "$1" | \
grep "$2" | \
grep -e "freeMemory.value" -e "totalMemory.value" | \
awk -F ";" '
/freeMemory.value/ {
   freeMemory=$9
}
/totalMemory.value/ {
   print $0";freeMemory.value;"freeMemory
}' 
