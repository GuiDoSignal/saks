#!/bin/bash

WAS_PROFILE="/opt/IBM/WebSphere/AppServer/profiles"

### Check whether we have all the parameters
if [[ $# -ne 1 ]]; then
   echo "USAGE>     ./${SCRIPT_NAME}.sh [WEBSPHERE_PROFILE]"
   echo
   exit 1;
fi

RESOURCES=$(find ${WAS_PROFILE}/$1/config/cells -maxdepth 2 -type f -name "resources.xml")
PORTS=$(find ${WAS_PROFILE}/$1/properties -maxdepth 2 -type f -name "portdef.props")
SERVER=$(find ${WAS_PROFILE}/$1/config/cells -maxdepth 6 -type f -name "server.xml" | grep -v templates)

if [[ ! -d ${WAS_PROFILE}/$1 || ! -f ${RESOURCES} ]]; then
   echo "ERROR> Profile $1 does not exist or it is invalid!";
   echo "ERROR> Quiting..."
   exit 2;
fi

## Checklisting instance
echo -e "\n### Checklisting $1 WebSphere instance on $(hostname -f)"

## Check JVM parameters
echo -e "\n### Listing JVM and system parameters"

awk '
/<jvmEntries / {
   if( match($0, /verboseModeClass="[^"]*"/) ){
      vmc=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /verboseModeGarbageCollection="[^"]*"/) ){
      vmgc=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /verboseModeJNI="[^"]*"/) ){
      vmj=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /initialHeapSize="[^"]*"/) ){
      ihs=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /maximumHeapSize="[^"]*"/) ){
      mhs=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /runHProf="[^"]*"/) ){
      rh=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /hprofArguments="[^"]*"/) ){
      rha=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /debugMode="[^"]*"/) ){
      dm=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /debugArgs="[^"]*"/) ){
      da=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /genericJvmArguments="[^"]*"/) ){
      gja=substr($0, RSTART, RLENGTH)
   }
   printf("%-40s %-40s %-40s\n", vmc, vmgc, vmj)
   printf("%-40s %-40s %-40s\n", ihs, mhs,  rh)
   printf("%-40s %-40s\n"      , rha, dm)
   printf("%-40s\n"            , da)
   printf("%-40s\n\n"          , gja)

   foundJVM="true"
   next;
}

foundJVM == "true" && /<systemProperties / {
   if( match($0, /name="[^"]*"/) ){
      name=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /value="[^"]*"/) ){
      value=substr($0, RSTART, RLENGTH)
   }
   printf("%-45s %-25s\n", name, value)

   next;
}

/<\/jvmEntries>/ {
   foundJVM="false"
   next;  
}' $SERVER

## Check profile ports
echo -e "\n### Listing instance ports"

awk -F"=" '/=/ { printf("%-50s %-10s\n", $1, $2); }' $PORTS

## Check datasource configuration
echo -e "\n### Listing JDBC providers"

awk '
/<resources.jdbc:JDBCProvider/ {
   if( match($0, /name="[^"]*"/) ){
      name=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /providerType="[^"]*"/) ){
      prov=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /xa="[^"]*"/) ){
      xa=substr($0, RSTART, RLENGTH)
   }
   printf("%-45s %-45s %-15s\n", name, prov, xa)

   next;
}' ${RESOURCES}

echo -e "\n### Listing JDBC factories and its configuration"

awk '
/<factories xmi:type="resources.jdbc:DataSource"/ {
   if( match($0, /name="[^"]*"/) ){
      name=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /jndiName="[^"]*"/) ){
      jndi=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /providerType="[^"]*"/) ){
      prov=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /authDataAlias="[^"]*"/) ){
      auth=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /statementCacheSize="[^"]*"/) ){
      stmt=substr($0, RSTART, RLENGTH)
   }
   printf("%-50s %-35s %-35s\n", name, jndi, prov)
   printf("%-50s %-35s\n"      , auth, stmt)

   foundJDBC="true";
   next;
}

foundJDBC == "true" && /<connectionPool/ {
   if( match($0, /connectionTimeout="[^"]*"/) ){
      connT=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /maxConnections="[^"]*"/) ){
      maxC=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /minConnections="[^"]*"/) ){
      minC=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /reapTime="[^"]*"/) ){
      reapT=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /unusedTimeout="[^"]*"/) ){
      unusedT=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /agedTimeout="[^"]*"/) ){
      agedT=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /purgePolicy="[^"]*"/) ){
      purgeP=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /testConnection="[^"]*"/) ){
      testC=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /testConnectionInterval="[^"]*"/) ){
      testConnI=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /stuckTimerTime="[^"]*"/) ){
      stuckTimerT=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /stuckTime="[^"]*"/) ){
      stuckT=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /stuckThreshold="[^"]*"/) ){
      stuckThres=substr($0, RSTART, RLENGTH)
   }
   printf("%-50s %-35s %-25s\n", connT,       maxC,    minC)
   printf("%-50s %-35s %-25s\n", reapT,       unusedT, agedT)
   printf("%-50s %-35s %-25s\n", purgeP,      testC,   testConnI)
   printf("%-50s %-35s\n\n"    , stuckTimerT, stuckT,  stuckThres)

   foundJDBC="false"
   next;
}' ${RESOURCES}

## Check thread pool configuration

echo -e "\n### Listing thread pool configuration"

awk '
/<threadPools / {
   if( match($0, /name="[^"]*"/) ){
      name=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /minimumSize="[^"]*"/) ){
      minS=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /maximumSize="[^"]*"/) ){
      maxS=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /inactivityTimeout="[^"]*"/) ){
      inact=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /isGrowable="[^"]*"/) ){
      isG=substr($0, RSTART, RLENGTH)
   }
   printf("%-40s %-20s %-20s %-25s %-20s\n", name, minS, maxS, inact, isG)

   next;
}' ${SERVER}

## Check thread pool configuration

echo -e "\n### Listing Mail Session configuration"

awk '
/<factories xmi:type="resources.mail:MailSession" / {
   if( match($0, /name="[^"]*"/) ){
      name=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /jndiName="[^"]*"/) ){
      jndi=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /mailTransportHost="[^"]*"/) ){
      mth=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /mailTransportPassword="[^"]*"/) ){
      mtPass=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /mailStorePassword="[^"]*"/) ){
      msp=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /debug="[^"]*"/) ){
      dbg=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /strict="[^"]*"/) ){
      strict=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /mailTransportProtocol="[^"]*"/) ){
      mtProt=substr($0, RSTART, RLENGTH)
   }
   printf("%-50s %-50s %-40s\n", name  , jndi,  mth)
   printf("%-50s %-50s %-40s\n", mtPass, msp ,  dbg)
   printf("%-50s %-50s\n"      , strict, mtProt)

   foundMAIL="true"
   next;
}

foundMAIL == "true" && /<resourceProperties / {
   if( match($0, /name="[^"]*"/) ){
      name=substr($0, RSTART, RLENGTH)
   }
   if( match($0, /value="[^"]*"/) ){
      value=substr($0, RSTART, RLENGTH)
   }
   printf("%-50s %-25s\n\n", name, value)

   next;
}

/<\/propertySet>/ {
   foundMAIL="false"
   next;  
}' ${RESOURCES}
