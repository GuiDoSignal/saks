#!/bin/bash

INPUT=$1

if [[ -z "$INPUT" ]];
then
   echo "## ERROR: no file provided for analysis!"
   echo "Usage: $0 <webservices-system-err> [<max-stack-length>]"
   exit 1
fi

STACK=$2
if [[ -z "$STACK" ]];
then
   STACK=500
fi

if [[ "$(file -ib $INPUT)" != "application/x-gzip; charset=binary" ]];
then
   echo "## ERROR: the given input file is not gzipped!"
   exit 2
fi

zcat $INPUT | \
awk -v maxStack=$STACK  ' 
function replaceErrors(lineStr) {
  ## log4j:ERROR Could not instantiate appender named "ERROR".
  sub(/appender named ".+"\./, "appender named ##appender##.", lineStr);

  ## log4j:ERROR Could not find value for key log4j.appender.INFO
  sub(/value for key .+\..+$/, "value for key ##key##", lineStr);

  ##para a propriedade logging.idSystem
  sub(/para a propriedade .+\..+$/, "para a propriedade ##propriedade##", lineStr);

  return(lineStr)
}

function fillBuffer(initial, start) {
   auxBuf = initial

   ## fill buffer and remove tab
   for(i = start; i<=NF; i++) {
      auxBuf = auxBuf " " $i
   }
   sub(/\t/, "", auxBuf);

   return(auxBuf)
}

function printArray(array){
   for(item in array) {
      print array[item], item
   }  
}

BEGIN {
   FS="     [REW] "
   buffer=""
   OFS=";"
}

## Com data e eh erro
$1 ~ /^\[..?\/..?\/.. / && $2 !~ /^\tat / { 
   ## Temos um erro "raiz" no buffer
   if( buffer != "" ){
      buffer = replaceErrors(buffer)
      bufLength = length(buffer)

      ## limita o tamanho do erro que fica em memoria
      if(bufLength  > maxStack) {
         buffer = substr(buffer, 0, maxStack/2) " #cut# " substr(buffer, bufLength + 7 - maxStack/2)
      }

      ## tira do buffer e armazena no catalogo de erros
      erros[buffer]++
   }

   ## fill buffer and remove tab
   buffer = fillBuffer("", 2)

   next
}

## Com data e eh stacktrace
$1 ~ /^\[..?\/..?\/.. / && $2 ~ /^\tat / { 
   ## Há um erro existente, portanto adicionamos a stacktrace
   if( buffer != "" ) {
      ## fill buffer and remove tab
      buffer = fillBuffer(buffer, 2)
   }

   next
}

## Sem data e eh stacktrace
/^\tat / {
   ## Há um erro existente, portanto adicionamos a stacktrace
   if( buffer != "" ) {
      ## fill buffer and remove tab
      buffer = fillBuffer(buffer, 1)
   }

   next
}

END {
   if( buffer != "" ) {
      buffer = replaceErrors(buffer)
      bufLength = length(buffer)

      if(bufLength  > maxStack) {
         buffer = substr(buffer, 0, maxStack/2) " #cut# " substr(buffer, bufLength + 7 - maxStack/2)
      }

      erros[buffer]++
   }

   printArray(erros)
}
' | sort -t ";" -n -r
