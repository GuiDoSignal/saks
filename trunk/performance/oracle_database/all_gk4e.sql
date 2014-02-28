--------------------------------------------------------------------------------
-- File name:   all_gk4e.sql
-- Purpose:     Generate Kill command for active session waiting for an specfici event
-- Author:      Thiago Maciel
-- Usage:       Run @all_gk4e.sql and provide the wait event name
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on
col command format a60;
col event format a60;

select  'alter system kill session '''||s.sid||','||s.serial#||''' immediate;' as "command",
        t.event
from    v$session s,
        v$session_wait t
where   upper(t.event) LIKE upper('&EVENT')
        and t.sid = s.sid
/
