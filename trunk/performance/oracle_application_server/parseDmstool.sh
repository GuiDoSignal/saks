#!/bin/bash

################ Not configurable section 

if [[ $# -ne 1 ]]
then
  echo "`date +'%d/%b/%Y %H:%M:%S'` [Error] Wrong numbers of parameters $#"
  echo "Usage: `basename $0` <gziped_file>" 
  exit 1
fi

zcat "$1" | \
awk '
BEGIN {
   FS="['\''\\[\\]\"]"
   OFS=";"
   header=0
}

NF == 11 {
    if ($3 == " id=") {
       id=$4
       host=$6
       name=$8
       timestamp=$10
       
    } else if ($3 == " name=" ) {
       id=$8
       host=$6
       name=$4
       timestamp=$10
    }
}

NF == 5 && $1 == "<noun name=" {
      nounName=$2
      nounType=$4
}

NF == 3 && $1 == "<metric name=" {
      metricName=$2        
}

NF == 7 && $1 == "<value type=" {
   metricType=$2
   metricValue=$5

   if(header == 0){
       print "id","host","name","timestamp","nounName","nounType","metricName","metricType","metricValue"
       header=1
   }

   print id,host,name,timestamp,nounName,nounType,metricName,metricType,metricValue
} '
