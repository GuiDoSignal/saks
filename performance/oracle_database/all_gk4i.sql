--------------------------------------------------------------------------------
-- File name:   all_gk4i.sql
-- Purpose:     Generate Kill command for active session waiting for a sql id
-- Author:      Thiago Maciel
-- Usage:       Run @all_gk4i.sql and provide the sql id
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on
col command format a60;

select 'alter system kill session '''||s.sid||','||s.serial#||''' immediate;' as "command",
        s.sql_id,
        t.event
from    v$session s,
        v$session_wait t
where   s.sql_id = '&sqlid'
and     t.sid = s.sid
/
