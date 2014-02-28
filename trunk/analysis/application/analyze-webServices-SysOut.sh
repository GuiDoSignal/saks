#!/bin/bash

INPUT=$1

if [[ -z "$INPUT" ]];
then
   echo "## ERROR: no file provided for analysis!"
   echo "Usage: $0 <webservices-system-out> [<max-stack-length>]"
   exit 1
fi

STACK=$2
if [[ -z "$STACK" ]];
then
   STACK=500
fi

if [[ "$(file -ib $INPUT)" != "application/x-gzip; charset=binary" ]]; then
   echo "## ERROR: the given input file is not gzipped!"
   exit 2
fi;

zcat $INPUT | \
awk -v maxStack=$STACK '
function replaceErrors(lineStr) {
   ## Host to handle /modules.php has not been
   sub(/Host to handle .* has not been/, "Host to handle ##page## has not been", lineStr);

   ## IllegalArgumentException: /../../../../../../../../../../../../etc/passwd at com.ibm.ws
   sub(/IllegalArgumentException: .* at com.ibm.ws/, "IllegalArgumentException: ##argument## at com.ibm.ws", lineStr);

   ## Business Group Id: 1356
   sub(/Business Group Id: [0-9]+/, "Business Group Id: ##group_id##", lineStr);

   ## Business Group: br.com.sodexho.ebs.vo.BusinessGroupVO@fd994532
   sub(/Business Group: .+@.+/, "Business Group: ##vo##", lineStr);

   ##WTRN0075W: Transaction WEBS#ebs-ws.war#AxisServlet 8046C2F037FA9FFF38840587C5EDA86B53A6EB8E0800000001 received
   sub(/WTRN0075W: Transaction .+ .+ received/, "WTRN0075W: Transaction ##servlet## ##hash## .+ received", lineStr);

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
   FS=" [REW] "
   buffer=""
}

## Temos data separada por indicador de erro (portanto temos erro)
$1 ~ /^\[..?\/..?\/.. / && NF == 2 { 
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

## Temos stacktrace
$1 ~ /^\tat / {
   ## Há um erro existente, portanto adicionamos a stacktrace
   if( buffer != "" ) {
      ## fill buffer and remove tab
      buffer = fillBuffer(buffer, 1)
   }

   next
}

NR == 100 {exit}
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
