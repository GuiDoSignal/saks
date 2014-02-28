#!/bin/sh
#
# Script to parse OSWatcher iostat collections
# To use, go in to the "archive" directory of OSWatcher output and run the script
# Check for proper environment

if [ -z `ls | grep oswiostat` ]; then
   echo "$PWD is not a OSWatcher archive directory. Exiting"
   exit 1
fi

cd oswiostat

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
'
# Temporarily create a big file to work on
zcat `head -$FE filelist | tail -$FD` > to_be_analyzed

awk '

function setArrayElemsToValue(anArray, aValue) { for(i in anArray) {anArray[i] = aValue}; }

BEGIN { tStamp="###"; OFS=";"  }

# When we match this kind of line, we should keep the timestamp. Example:
##   zzz ***Wed May 12 10:39:12 BRT 2010

NF == 7 {
   if( tStamp == "###" ){
      tStamp=$4"/"$3"/"$7" "$5
      print "tStamp","dev","avg bps","cnt bps","avg sps","cnt sps","avg msps","cnt msps"

   } else {
      for(dev in sum_bps){
          printf " %s; %s;",        tStamp, dev
          printf " %4.3f; %4d;",   sum_bps[dev]/count_bps[dev],   count_bps[dev]
          printf " %4.3f; %4d;",   sum_sps[dev]/count_sps[dev],   count_sps[dev]
          printf " %4.3f; %4d;\n", sum_msps[dev]/count_msps[dev], count_msps[dev]
      }
      tStamp=$4"/"$3"/"$7" "$5
      setArrayElemsToValue(sum_bps,0);   setArrayElemsToValue(count_bps,0);
      setArrayElemsToValue(sum_sps,0);   setArrayElemsToValue(count_sps,0);
      setArrayElemsToValue(sum_msps,0);  setArrayElemsToValue(count_msps,0);
   }
}

NF == 4 && $NF !~ /[a-z]+/ {
   sum_bps[$1]    = sum_bps[$1]    + $2
   count_bps[$1]  = count_bps[$1]  + 1
   sum_sps[$1]    = sum_sps[$1]    + $3
   count_sps[$1]  = count_sps[$1]  + 1
   sum_msps[$1]   = sum_msps[$1]   + $4
   count_msps[$1] = count_msps[$1] + 1
}

END {
   for(dev in array_bps){
       printf " %s; %s;",        tStamp, dev
       printf " %4.3f; %4d;",   sum_bps[dev]/count_bps[dev],   count_bps[dev]
       printf " %4.3f; %4d;",   sum_sps[dev]/count_sps[dev],   count_sps[dev]
       printf " %4.3f; %4d;\n", sum_msps[dev]/count_msps[dev], count_msps[dev]
   }
}
' to_be_analyzed > ../iostat_parsedData.csv

echo "The files were parsed. Please check the file iostat_parsedData.csv in the current directory."
rm to_be_analyzed filelist
