--------------------------------------------------------------------------------
-- File name:   all_ln.sql
-- Purpose:     Check which Latches are happening Now.
-- Author:      Thiago Azevedo
-- Usage:       Run @all_ln.sql
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on
column username format A15 justify left word_wrap
column program format A15 justify left word_wrap
column machine format A20 justify left word_wrap
column "Event name" format A35 justify left word_wrap
column sql_text format A60 wrapped justify left word_wrap
column sid format 99999999
column sql_hash_value, format 99999999

SELECT SW.SID,
       S.USERNAME,
       S.PROGRAM,
       S.machine,
       SW.EVENT || ' - ' || L.NAME as "Event name",
       ST.hash_value,
       ST.sql_text
FROM  V$SESSION_WAIT SW,
      V$SESSION   S,
      V$LATCH     L,
      V$SQLTEXT   ST
WHERE SW.EVENT = 'latch free'
  AND SW.P2 = L.LATCH#
  AND S.SID = SW.SID
  AND S.SQL_HASH_VALUE  = ST.HASH_VALUE
  and ST.piece = 0
/