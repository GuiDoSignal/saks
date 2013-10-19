#!/bin/bash

TMP_FILE="/tmp/update-ports.txt"

######################################################## Non configurable section ##########################################
script_name=$(basename $0 .sh)

### Check whether we have all the parameters
if [[ $# -ne 5 ]]; then
   echo -e "USAGE>     ./${script_name}.sh [WAS_HOME] [PROFILE_NAME] [NODE_NAME] [CELL_NAME] [PORTS_FILE]\n"
   echo    "   [WAS_HOME]     is the directory where the WebSphere is installed (ends in AppServer)"
   echo    "   [PROFILE_NAME] is the name of the profile which will be updated"
   echo    "   [NODE_NAME]    is the name of the node which will be updated"
   echo    "   [CELL_NAME]    is the name of the cell which will be updated"
   echo -e "   [PORTS_FILE]   is the file with the ports you want to set the profile to\n"
   echo "EXAMPLE>   ./${script_name}.sh /opt/IBM/WebSphere/AppServer CVV kepler009Node01Cell kepler009Node01 /tmp/portdef.props"
   exit 1;
fi

was_home="$1"
aProfile="$2"
aNode="$3"
aCell="$4"
aPortsFile="$5"

echo "was.install.root=${was_home}"                             > ${TMP_FILE}
echo "profileName=${aProfile}"                                 >> ${TMP_FILE}
echo "profilePath=${was_home}/profiles/${aProfile}"            >> ${TMP_FILE}
echo "templatePath=${was_home}/profileTemplates/default"       >> ${TMP_FILE}
echo "nodeName=${aNode}"                                       >> ${TMP_FILE}
echo "cellName=${aCell}"                                       >> ${TMP_FILE}
echo "hostName=$(hostname).$(dnsdomainname)"                   >> ${TMP_FILE}
echo "portsFile=${aPortsFile}"                                 >> ${TMP_FILE}

${was_home}/bin/ws_ant.sh -propertyfile ${TMP_FILE} -file ${was_home}/profileTemplates/default/actions/updatePorts.ant

rm ${TMP_FILE}

