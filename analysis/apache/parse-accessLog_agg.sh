#!/bin/bash

#######################################################################################################
# Description: this parse calculates the average time taken to serve each page per hour and per day   #
#              It removes the parameters provided after '?' ou ';'                                    #
# Parameters (in order):                                                                              #
#    SEP             - the separator between fields inside each file (usually ' ')                    #
#    DATE_FIELD      - Index of the field that contains the date (usually 5)                          #
#    CATEG_FIELD     - Index of the field that will be used for aggregation after the aggregation     #
#                      based on the date or NONE if you dont want a second aggregation                #
#    VALUE_FILED     - Index of the field or value of the constant to used during the aggregation     #
#######################################################################################################

SEP=$1
DATE_FIELD=$2
CATEG_FIELD=$3
AGG_VALUE=$4

######################################################################################################
############################ Non configurable section below this line ################################

if [[ -z "$SEP"  || -z "$DATE_FIELD" || -z "$CATEG_FIELD" || -z "$AGG_VALUE" ]]
then
  echo
  echo "Not all parameters have been provided or set properly."
  echo "Usage: $(basename $0) SEP DATE_FIELD CATEG_FIELD VALUE_FIELD"
  echo "Alternate usage: $(basename $0) (with parameters set internally)"
  echo
  exit 1
fi

awk -F "$SEP" -v dateField=$DATE_FIELD -v aggCateg=$CATEG_FIELD -v aggValue=$AGG_VALUE '
function getDateString(anDate) {
   #Example: [16/Sep/2010:00:00:17 -0300]
   num = split(anDate, arrayDate, ":")

   dateStr = substr(arrayDate[1],2)

   return dateStr
}

function getHourString(anDate) {
   #Example: [16/Sep/2010:00:00:17 -0300]
   num = split(anDate, arrayDate, ":")

   hourStr = arrayDate[2]
 
   quarterHour    = int(arrayDate[3]/15) * 15
   quarterHourStr = sprintf("%02d",quarterHour)

   return hourStr ":" quarterHourStr
}

BEGIN {
   OFS=";"
   print "Group","Date","Hour","Value","Count"
}

{  
   date   = getDateString($dateField)
   hour   = getHourString($dateField)

   if(aggCateg == "NONE") {
      agg["NONE" OFS date OFS hour]     += $aggValue  
      cnt["NONE" OFS date OFS hour]     += 1
   } else {
      categ = $aggCateg
      agg[categ OFS date OFS hour]      += $aggValue
      cnt[categ OFS date OFS hour]      += 1
   }
}

END {
   for(i in agg) {
      print i, agg[i], cnt[i]
   }
}'
