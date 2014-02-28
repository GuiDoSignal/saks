#!/bin/bash

################ Not configurable section ###################

# The prefix name for the output files' names. Usually, this is the host name.
PREFIX=`hostname`

if [[ $# -ne 3 ]]
then
  echo "`date +'%d/%b/%Y %H:%M:%S'` [Error] Wrong numbers of parameters $#"
  echo "Usage: `basename $0` sarDir sarFilesPattern outputDir"
  exit 1
fi

IN_DIR=$1
PATTERN=$2
OUT_DIR=$3

FILES=`ls ${IN_DIR}/${PATTERN}`

export LC_ALL=C

echo "Gerando saidas do sar em texto..."

for aFile in $FILES; do
   echo -n "Processing ${aFile}..."
   
   #### All metrics
   sar -A -f ${aFile} >> ${OUT_DIR}/${PREFIX}_`basename ${aFile}`_allMetrics.txt

   echo "done!"
done;