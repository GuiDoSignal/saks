--------------------------------------------------------------------------------
-- File name:   9i_alo.sql
-- Purpose:     Get info of the active long operations
-- Author:      Guilherme Botelho Diniz Junqueira
-- Usage:       Run @9i_alo.sql
--------------------------------------------------------------------------------

SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on

col "Running (seg)" format 09
col start_time format a16
col last_update_time format a16
col PCT format 999D99
col message format a70

select sid,
       (sysdate - start_time) * 24 * 60 * 60 as "Running (seg)",
       to_char(start_time, 'dd/mm/rr hh24:mi') as Start_Time,
       to_char(last_update_time, 'dd/mm/rr hh24:mi') as last_update_time,
       round(sofar/totalwork,4)*100 pct,
       sofar,
       totalwork,
       message
from v$session_longops
where totalwork !=0
and sofar < totalwork
and sid in (select sid from v$session where status = 'ACTIVE');