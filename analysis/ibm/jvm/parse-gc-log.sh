#!/bin/bash

awk ' 

BEGIN {
   FS="\""
   OFS=";"
}

NR == 1 {
    print "date","time","id","freebytes (before)","totalbytes (before)","intervalms","freebytes (after)","totalbytes (after)","totalms"; 
}
   
/<af type="tenured"/,/<\/af>/{
   if( $0 ~ /<af type="tenured"/ ){
      beforeGC=0
      id=$4
      split($6,dates," ")
      date=dates[3]"/"dates[2]"/"dates[5]
      time=dates[4]
   }
    
   if( $0 ~ /<tenured/ ){
      if( beforeGC==0 ){
         freeBeforeGC=$2
         totalBeforeGC=$4
         beforeGC=1
         
      }else{
         freeAfterGC=$2
         totalAfterGC=$4
      }
   }

   
   if( $0 ~ /<gc type="global"/ ){
      intervalms=$8
   }
   
   if( $0 ~ /<time totalms=/ ){
      totalms=$2
   }
   
   if( $0 ~ /<\/af>/ ){
      print date,time,id,freeBeforeGC,totalBeforeGC,intervalms,freeAfterGC,totalAfterGC,totalms
   }
} 
' 