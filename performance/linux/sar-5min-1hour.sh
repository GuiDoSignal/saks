#!/bin/bash

INM_HOME="/home/wasadmin/inmetrics"
OUTPUT_LOG="${INM_HOME}/logs/$(basename $0 .sh).log"

################################ NON CONFIGURABLE SECTION ############################
SADC=$(which sadc)
MONTHLY_FOLDER=$(date '+%Y_%m')
DATA_FILE="${INM_HOME}/coletas/sa/${MONTHLY_FOLDER}/sa_$(date +%F)"

if [ ! -d "${INM_HOME}/coletas/sa/${MONTHLY_FOLDER}" ]
then
    mkdir -p "${INM_HOME}/coletas/sa/${MONTHLY_FOLDER}"
fi

if [[ pgrep -o -f ${DATA_FILE} ]];
then
   echo "ERROR! There is a sadc instance running for the same output file!"
else
   ${SADC} -F -L 300 12 ${DATA_FILE}
fi
