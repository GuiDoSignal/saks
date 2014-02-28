#!/bin/bash
#
# Script to parse OSWatcher vmstat collections
# To use, go in to the "archive" directory of OSWatcher output and run the script
# Check for proper environment
if [ -z `ls | grep oswtop` ]; then
   echo "$PWD is not a OSWatcher archive directory. Exiting"
   exit 1
fi
cd oswtop

# Specify range to be analyzed
ls -1tr *.dat.gz > filelist
cat filelist

echo "Enter starting file name:"
echo -n ">> "
read FILE_BEGIN

echo "Enter ending file name:"
echo -n ">> "
read FILE_END

FB=`grep -n $FILE_BEGIN filelist | awk -F: {'print $1'}`
FE=`grep -n $FILE_END filelist | awk -F: {'print $1'}`
FD=`echo "$FE - $FB + 1" | bc`

# Temporarily create a big file to work on
zcat `head -$FE filelist | tail -$FD` > to_be_analyzed

awk '
function getOSWatcherTimestamp(){
   return($7 "/" $3 "/" $4 " " $5)
}

BEGIN {
   header="DATE-HOUR;PID;USER;PR;NI;VIRT;RES;SHR;S;%CPU;%MEM;TIME+;COMMAND"
   timestamp="###";
   OFS=";"
}

# When we match this kind of line, we should keep the timestamp. Example:
$1 ~ /zzz/ {
   if( timestamp == "###" ){
       print header
   }
   timestamp=getOSWatcherTimestamp();
}

NF == 12 && $1 ~ /[0-9]+/ {
   print timestamp,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12
}

' to_be_analyzed > ../top_parsedData.csv

echo "The files were parsed. Please check the file top_parsedData.csv in the current directory."

rm to_be_analyzed filelist
