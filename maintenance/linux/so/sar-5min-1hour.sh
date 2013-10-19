#!/bin/bash

INM_HOME="/home/wasadmin/inmetrics"
OUTPUT_LOG="/home/wasadmin/inmetrics/logs/`basename $0 .sh`.log"

################################ NON CONFIGURABLE SECTION ############################
MONTHLY_FOLDER=`date '+%Y_%m'`

# Store PID of script
LCK_FILE="${INM_HOME}/coletas/sa/`basename $0 .sh`.lck"

if [ ! -d "${INM_HOME}/coletas/sa/${MONTHLY_FOLDER}" ]
then
    mkdir -p "${INM_HOME}/coletas/sa/${MONTHLY_FOLDER}"
    echo "" > $LCK_FILE
fi

# Checking whether an process is running or not
if [ -f "${LCK_FILE}" ]; then
  MYPID=`head -n 1 $LCK_FILE`

  if [ -n "`ps -p ${MYPID} | grep -w ${MYPID}`" ]; then
    echo `date`" -> "`basename $0` is already running [$MYPID] >> ${OUTPUT_LOG}
    exit
  fi
fi

# Echo current PID into lock file
echo $$ > $LCK_FILE

/usr/lib64/sa/sadc 300 12 ${INM_HOME}/coletas/sa/${MONTHLY_FOLDER}/sa_`date +%F`
