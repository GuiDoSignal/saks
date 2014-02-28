#!/bin/bash
user='scriptaudit'
senha='123456'

#########################################################################
INM_HOME="/tmp/inmetrics"
PID1="${INM_HOME}/coletas_WS/collectServerPPW.pid"
PID2="${INM_HOME}/coletas_WS/collectAppSrv01.pid"

OUT_LOG_FILE1="${INM_HOME}/coletas_WS/collectServerPPW.log"
OUT_LOG_FILE2="${INM_HOME}/coletas_WS/collectAppSrv01.log"

ERR_LOG_FILE1="${INM_HOME}/coletas_WS/inmetricsServerPPW.log"
ERR_LOG_FILE2="${INM_HOME}/coletas_WS/inmetricsAppSrv01.log"

CMD=$1

case ${CMD} in
__RUN1)
  ## The command to run comes here
  echo `date`

  /opt/IBM/WebSphere/AppServer/profiles/serverPPW/bin/wsadmin.sh \
  -host localhost -port 8881 -username $user -password $senha -lang jython \
  -f ${INM_HOME}/scripts/wasmonitor_pos6-1.py \
  "beanModule,connectionPoolModule,jvmRuntimeModule,servletSessionsModule,threadPoolModule" \
  ${INM_HOME}/coletas_WS/serverPPW

  rm ${PID1}
  find ${INM_HOME}/coletas_WS/serverPPW/ -type f -exec chmod 0777 {} \;
  ;;

__RUN2)
  ## The command to run comes here
  echo `date`

  /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/bin/wsadmin.sh \
  -host localhost -port 8880 -username $user -password $senha -lang jython \
  -f ${INM_HOME}/scripts/wasmonitor_pos6-1.py \
  "beanModule,connectionPoolModule,jvmRuntimeModule,servletSessionsModule,threadPoolModule" \
  ${INM_HOME}/coletas_WS/AppSrv01

  rm ${PID2}
  find ${INM_HOME}/coletas_WS/AppSrv01/ -type f -exec chmod 0777 {} \;
  ;;

*)
  if [ -r ${PID1} ]; then
     PROC_EXISTS1=`ps -ef | fgrep -f ${PID1}`
  else
     PROC_EXISTS1=
  fi

  if [ -z "${PROC_EXISTS1}" ]; then
     nohup $0 __RUN1 1>> ${OUT_LOG_FILE1} 2>&1 &
     PROC_ID1=$!
     echo ${PROC_ID1} > ${PID1}
     echo "`date` - Process `cat ${PID1}` was started to collect Websphere data." >> ${ERR_LOG_FILE1}
  else
     echo "`date` - Websphere data could not be collected because process `cat ${PID1}` is still runnning." >> ${ERR_LOG_FILE1}
  fi

  if [ -r ${PID2} ]; then
     PROC_EXISTS2=`ps -ef | fgrep -f ${PID2}`
  else
     PROC_EXISTS2=
  fi

  if [ -z "${PROC_EXISTS2}" ]; then
     nohup $0 __RUN2 1>> ${OUT_LOG_FILE2} 2>&1 &
     PROC_ID2=$!
     echo ${PROC_ID2} > ${PID2}
     echo "`date` - Process `cat ${PID2}` was started to collect Websphere data." >> ${ERR_LOG_FILE2}
  else
     echo "`date` - Websphere data could not be collected because process `cat ${PID2}` is still runnning." >> ${ERR_LOG_FILE2}
  fi
  ;;
esac
