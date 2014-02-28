#!/bin/bash

################ Not configurable section 

if [[ $# -ne 4 ]]
then
  echo "`date +'%d/%b/%Y %H:%M:%S'` [Error] Wrong numbers of parameters $#"
  echo "Usage: `basename $0` sarDir sarFilesPattern outputDir outputPrefix"
  exit 1
fi

IN_DIR=$1
PATTERN=$2
OUT_DIR=$3
PREFIX=$4

FILES=`ls ${IN_DIR}/${PATTERN}`

export LC_ALL=C

echo "Gerando saidas do sar em texto..."

for aFile in $FILES; do
   echo -n "Processing ${aFile}..."
   
   #### CPU simple
   sar -u -f ${aFile} >> ${OUT_DIR}/${PREFIX}_CPU_simple.txt
      	
   #### CPU detailed 
   sar -P ALL -f ${aFile} >> ${OUT_DIR}/${PREFIX}_CPU_detailed.txt
   
   #### PAGINACAO
   sar -B -f ${aFile} >> ${OUT_DIR}/${PREFIX}_PAGING.txt

   #### I/O
   sar -d -f ${aFile} >> ${OUT_DIR}/${PREFIX}_IO.txt

   #### REDE traffic
   sar -n DEV -f ${aFile} >> ${OUT_DIR}/${PREFIX}_NETWORK_TRAFFIC.txt

   #### REDE errors
   sar -n EDEV -f ${aFile} >> ${OUT_DIR}/${PREFIX}_NETWORK_ERRORS.txt

   #### REDE sockets
   sar -n SOCK -f ${aFile} >> ${OUT_DIR}/${PREFIX}_NETWORK_SOCKETS.txt

   #### REDE errors
   sar -n EDEV -f ${aFile} >> ${OUT_DIR}/${PREFIX}_NETWORK_ERRORS.txt

   #### REDE sockets
   sar -n SOCK -f ${aFile} >> ${OUT_DIR}/${PREFIX}_NETWORK_SOCKETS.txt

   #### MEMORIA
   sar -r -f ${aFile} >> ${OUT_DIR}/${PREFIX}_MEMORY.txt

   #### RunQueue
   sar -q -f ${aFile} >> ${OUT_DIR}/${PREFIX}_RUNQUEUE.txt

   echo "done!"
done;
