awk '
  BEGIN { OFS=";";
          print "Data","failed connection attempts","connection resets received","segments retransmited","bad segments received","resets sent" }

  /zzz ... ... . ..:..:.. BRT ..../ {  lineBuffer = $4 "/" $3 "/" $7 " " $5; }

  /failed connection attempts/ {  lineBuffer = lineBuffer OFS $1;  }

  /connection resets received/ {  lineBuffer = lineBuffer OFS $1; }

  /segments retransmited/ { lineBuffer = lineBuffer OFS $1; }

  /bad segments received/ { lineBuffer = lineBuffer OFS $1; }

  /resets sent/ { lineBuffer = lineBuffer OFS $1; print lineBuffer; lineBuffer=""; }
'
