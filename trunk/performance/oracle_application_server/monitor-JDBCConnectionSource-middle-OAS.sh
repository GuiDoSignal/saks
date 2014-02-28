#!/bin/bash

# Time between each snapshot
INTERVAL="300"
# How many snapshots should be taken
COUNT="12"
# OAS installation directory
OAS_DIR="/apps/oracle/IAS10gR2/middle"
# Inmetrics home
INM_HOME="/home/oracle/inmetrics"

#################################### Non configurable section #####################################

FILENAME=`basename $0 .sh`
DAY=`date +%F`
MONTHLY_FOLDER=`date '+%Y_%m'`
OUTPUT_DIR="${INM_HOME}/coletas/${FILENAME}/${MONTHLY_FOLDER}"
OUTPUT_FILE="${OUTPUT_DIR}/${DAY}_${FILENAME}.txt"

if [ ! -d "${OUTPUT_DIR}" ]
then
    mkdir -p ${OUTPUT_DIR}
fi

metrics=`${OAS_DIR}/bin/dmstool -l | grep -e CacheSize.value -e CacheGetConnection.avg -e CacheFreeSize.value -e CacheHit.count -e CacheMiss.count`

${OAS_DIR}/bin/dmstool -i ${INTERVAL} -c ${COUNT}  ${metrics} | \
awk '
   NF == 6 { data=$0 }
   NF == 3 { print data,$0; system("") }
' >> ${OUTPUT_FILE}
