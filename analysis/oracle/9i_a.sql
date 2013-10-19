--------------------------------------------------------------------------------
-- File name:   9i_a0
-- Purpose:     Returns the number of active sessions executing the same SQL and waiting for the same event
-- Author:      Guilherme Botelho Diniz Junqueira
-- Usage:       Run @9i_a0.sql
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on

col SID format 999999
col SIDS format 999999

select count(*) as SIDS,
	   w.event
from v$session s,
     v$session_wait w
where s.status='ACTIVE'
  and s.type!='BACKGROUND'
  and s.sid=w.sid
group by event
order by 2, 1 desc
/

select s.sid as SID,
       s.sql_hash_value,
	   w.event
from v$session s,
     v$session_wait w
where s.status='ACTIVE'
  and s.type!='BACKGROUND'
  and s.sid=w.sid
order by 3, 1
/