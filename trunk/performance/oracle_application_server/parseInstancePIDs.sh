#!/bin/bash

################ Not configurable section 

grep "oracle_oc4j_instancename.value" | \
awk -F ";" '
{  if(lastInst[$NF] != $1){
      lastInst[$NF]=$1;
      inst[$NF]=inst[$NF]" "$1" (since: "$4")"
   }
}
END {
   for(i in inst){
      print "Instance: "i" PIDs:"inst[i]
   }
}'
