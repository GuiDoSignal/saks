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

function arrayAvg(aArray){ aAvg=aArray[0]+aArray[1]+aArray[2]; return(aAvg/3); }

BEGIN { timestamp="###"; OFS=";"  }

# When we match this kind of line, we should keep the timestamp. Example:
##   zzz ***Wed May 12 10:39:12 BRT 2010

NF == 7 {
   if( timestamp == "###" ){
      timestamp=$4"/"$3"/"$7" "$5

      print "timestamp","procs_r","procs_b","procs_w","memory_avm","memory_free","page_re","page_at","page_pi","page_po","page_fr","page_de","page_sr","page_in","faults_sy","faults_cs","cpu_us","cpu_sy","cpu_id"


   } else {
      print timestamp,arrayAvg(procs_r),arrayAvg(procs_b),arrayAvg(procs_w),arrayAvg(memory_avm),arrayAvg(memory_free),arrayAvg(page_re),arrayAvg(page_at),arrayAvg(page_pi),arrayAvg(page_po),arrayAvg(page_fr),arrayAvg(page_de),arrayAvg(page_sr),arrayAvg(page_in),arrayAvg(faults_sy),arrayAvg(faults_cs),arrayAvg(cpu_us),arrayAvg(cpu_sy),arrayAvg(cpu_id);
      timestamp=$4"/"$3"/"$7" "$5
   }
}

# When we match this kind of line, we reset the counters. Example:
##       procs           memory           page            faults       cpu

/^ +procs +memory +page +faults +cpu$/ {
   for(i=0;i<4;i++){
      procs_r[i]=0;     procs_b[i]=0;     procs_w[i]=0;       
      memory_avm[i]=0;  memory_free[i]=0; 
      page_re[i]=0;     page_at[i]=0;     page_pi[i]=0;  
      page_po[i]=0;     page_fr[i]=0;     page_de[i]=0;
      page_sr[i]=0;     page_in[i]=0;
      faults_sy[i]=0;   faults_cs[i]=0;   
      cpu_us[i]=0;      cpu_sy[i]=0;      cpu_id[i]=0;     
   }
   i=0;
}

# When we match the values, we store them for later
##    7   3   0  1427228   34792  271   34    12    7     0    0    19   4079 132543  2643  14  3 84

NF == 18 && $0 ~ /^[ 0-9]+$/ {
   procs_r[i]=$1;     procs_b[i]=$2;     procs_w[i]=$3;
   memory_avm[i]=$4;  memory_free[i]=$5;
   page_re[i]=$6;     page_at[i]=$7;     page_pi[i]=$8;
   page_po[i]=$9;     page_fr[i]=$10;    page_de[i]=$11;
   page_sr[i]=$12;    page_in[i]=$13;
   faults_sy[i]=$14;  faults_cs[i]=$15;
   cpu_us[i]=$16;     cpu_sy[i]=$17;     cpu_id[i]=$18;

   i++
}

' to_be_analyzed > ../vmstat_parsedData.csv

echo "The files were parsed. Please check the file vmstat_parsedData.csv in the current directory."
rm to_be_analyzed
