#!/bin/bash

################ Not configurable section 

if [[ $# -ne 2 ]]
then
  echo "`date +'%d/%b/%Y %H:%M:%S'` [Error] Wrong numbers of parameters $#"
  echo "Usage: `basename $0` <gziped_csv_file> <instancePID>" 
  exit 1
fi

####################### Sessions 
zcat "$1" | \
grep "$2" | \
grep -e "oc4j_context;sessionActivation.active" > $2_sessions.csv
