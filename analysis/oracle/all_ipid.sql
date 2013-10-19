--------------------------------------------------------------------------------
-- File name:   all_ipid
-- Purpose:     Get useful information of given PIDs
-- Author:      Guilherme Botelho Diniz Junqueira
-- Usage:       Run @all_ipid.sql and provide the PIDs
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on

column spid format 999999
column sid format 999999
column username format A15
column machine format A15
column program format A35
column hash_value format 9999999999
column sql_text format A65

SELECT  PP.SPID,
        SS.SID,
        SS.USERNAME,
        SS.MACHINE,
        SS.PROGRAM,
        ST.HASH_VALUE,
        ST.SQL_TEXT
FROM V$PROCESS PP,
     V$SESSION SS,
     V$SQLTEXT ST
WHERE PP.ADDR = SS.PADDR
    AND SS.SQL_HASH_VALUE  = ST.HASH_VALUE
    AND PP.SPID IN (&PIDS)
order by st.piece
/