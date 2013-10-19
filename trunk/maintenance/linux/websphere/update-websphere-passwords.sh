#!/bin/bash

SCRIPT_NAME=$(basename $0 .sh)

### Check whether we have all the parameters
if [[ $# -ne 4 ]]; then
   echo "USAGE>     ./${SCRIPT_NAME}.sh [WEBSPHERE_PROFILES_DIR] [BKP_DIR] [USERS] [NEW_PASS]"
   echo
   echo "   [USERS]    is comma separated argument or the reserved keyword ALL"
   echo "   [NEW_PASS] should NOT include the beginning {xor}"
   echo
   echo "EXAMPLE>   ./${SCRIPT_NAME}.sh /opt/IBM/WebSphere/AppServer/profiles /tmp \"joao,maria\" \"CxoMCxo=\""
   exit 1;
fi

WEBSPHERE_PROFILES_DIR=$1
BKP_DIR=$2
USERS=$3
NEW_PASS=$4
CHAR_BEF="/"
CHAR_AFT="_"

### Check if any WebSphere process is running
pids="$(pgrep -d " " -f "/opt/IBM/WebSphere/AppServer/java/bin/java" -u wasadmin)"
if [[ ! -z "$pids" ]]; then
   echo "ERROR> The following PIDs were found running WebSphere under \"wasadmin\" user: \"$pids\""
   echo "Exiting..."
   exit 1;
fi

echo "RUN> Beginning the password change!"
if [[ $? -eq 0 ]]; then
   for filepath in $(find ${WEBSPHERE_PROFILES_DIR} -maxdepth 5 -type f -name "security.xml");
   do
      echo 'RUN> Processing file "'"${filepath}"'"'

      ### Firstly, let's backup everything
      bkp_file="${BKP_DIR}/${filepath//$CHAR_BEF/$CHAR_AFT}"
      cp ${filepath} ${bkp_file}
      if [[ $? -eq 0 ]]; then
         awk -v vPASS="${NEW_PASS}" -v vUSERS="${USERS}" '
           BEGIN {
              if(vUSERS=="ALL") {
                 pattern="<authDataEntries .*userId=\".*\" password.*/>";
              } else {
                 gsub(/,/, "|", vUSERS)
                 pattern="<authDataEntries .*userId=\"" vUSERS "\" password.*/>";
              }
           }
 
           $0 ~ pattern {
              sub(/password=".*"/, "password=\"{xor}" vPASS "\"");
              print $0; 
              next;
           }
 
           {
              print
           }
         ' ${bkp_file} > ${filepath}
      fi
   done
   echo "RUN> Password change finished!"
fi

