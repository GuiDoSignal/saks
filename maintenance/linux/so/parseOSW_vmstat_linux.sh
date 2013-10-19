#!/bin/bash
#
# Script to parse OSWatcher vmstat collections
# To use, go in to the "archive" directory of OSWatcher output and run the script
# Check for proper environment
if [ -z `ls | grep oswvmstat` ]; then
   echo "$PWD is not a OSWatcher archive directory. Exiting"
   exit 1
fi
cd oswvmstat

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

function arrayAverage(aArray){ aAvg=aArray[0]+aArray[1]+aArray[2]; return(aAvg/3); }

BEGIN { timestamp="###"; OFS=";"  }

# When we match this kind of line, we should keep the timestamp. Example:
##   zzz ***Wed May 12 10:39:12 BRT 2010

NF == 7 {
   if( timestamp == "###" ){
      timestamp=$4"/"$3"/"$7" "$5
      print "timestamp","procs_r","procs_b","memory_swpd","memory_free","memory_buff","memory_cache","swap_si","swap_so","io_bi","io_bo","system_in","system_cs","cpu_us","cpu_sy","cpu_id","cpu_wa" 

   } else {
      print timestamp,arrayAverage(procs_r),arrayAverage(procs_b),arrayAverage(memory_swpd),arrayAverage(memory_free),arrayAverage(memory_buff),arrayAverage(memory_cache),arrayAverage(swap_si),arrayAverage(swap_so),arrayAverage(io_bi),arrayAverage(io_bo),arrayAverage(system_in),arrayAverage(system_cs),arrayAverage(cpu_us),arrayAverage(cpu_sy),arrayAverage(cpu_id),arrayAverage(cpw_wa)
      timestamp=$4"/"$3"/"$7" "$5
   }
}

# When we match this kind of line, we reset the counters. Example:
# procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----

/^procs[ -]+memory[ -]+swap[ -]+io[ -]+system[ -]+cpu-+$/ {
   for(i=0;i<4;i++){
      procs_r[i]=0;     procs_b[i]=0;        
      memory_swpd[i]=0; memory_free[i]=0; memory_buff[i]=0; memory_cache[i]=0;   
      swap_si[i]=0;     swap_so[i]=0;        
      io_bi[i]=0;       io_bo[i]=0;          
      system_in[i]=0;   system_cs[i]=0;      
      cpu_us[i]=0;      cpu_sy[i]=0;      cpu_id[i]=0;       cpu_wa[i]=0; 
   }
   i=0;
}

# When we match the values, we store them for later

NF == 16 && $0 ~ /^[ 0-9]+$/ {
   procs_r[i]=$1;     procs_b[i]=$2;
   memory_swpd[i]=$3; memory_free[i]=$4; memory_buff[i]=$5; memory_cache[i]=$6;
   swap_si[i]=$7;     swap_so[i]=$8;
   io_bi[i]=$9;       io_bo[i]=$10;
   system_in[i]=$11;  system_cs[i]=$12;
   cpu_us[i]=$13;     cpu_sy[i]=$14;      cpu_id[i]=$15;       cpu_wa[i]=$16;
   
   i++
}

' to_be_analyzed > ../vmstat_parsedData.csv

echo "The files were parsed. Please check the file vmstat_parsedData.csv in the current directory."
rm to_be_analyzed
