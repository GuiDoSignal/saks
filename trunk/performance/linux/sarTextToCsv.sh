#!/bin/bash

################ Not configurable section 

if [[ $# -ne 3 ]]
then
  echo "`date +'%d/%b/%Y %H:%M:%S'` [Error] Wrong numbers of parameters $#"
  echo "Usage: `basename $0` sarDir sarFilesPattern outputDir" 
  exit 1
fi

IN_DIR=$1
PATTERN=$2
OUT_DIR=$3

FILES=`ls ${IN_DIR}/${PATTERN}`

export LC_ALL=C

################ Not configurable section ################

FILES=`ls ${IN_DIR}/${PATTERN}`

for file in ${FILES}; do
   echo -n "Processing ${file}..."
   newFileName=`basename ${file}`
   cat ${file} | 
   awk -F "[ \t]+" '
   # Lines which do not end in digits are the headers
   /[^0-9]$/ { 
      if(header=="") {
         header="Maquina;Ano;Mes;Dia;Hora";
         for(i=2; i<=NF; i++) {
            if($i!=""){
               header=header";"$i
            }
         }
         print header
      };
   }

   # Lines which do not start with digits and end with date-like string
   /[^0-9].*[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]/ {
      MAQ=$3; 
      split($4,DATA,"/");
      MES=DATA[1]
      DIA=DATA[2]
      ANO=DATA[3]
   }

   # Lines which start and end with digits can be either a line with data or the runqueue header (FIX IT)
   /^[0-9][0-9].+[0-9]$/ {
      line=MAQ";"ANO";"MES";"DIA
      for(i=1; i<=NF; i++) {
         if($i!=""){
            line=line";"$i
         }
      }
      print line
   }
   ' > ${OUT_DIR}/${newFileName%.???}.csv
   echo "done!"
done;
