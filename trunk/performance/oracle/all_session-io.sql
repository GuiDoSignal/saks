--------------------------------------------------------------------------------
-- File name:   all_session-io
-- Purpose:
-- Author:      Thiago Maciel
-- Usage:       Run @all_session-io
--------------------------------------------------------------------------------
set lines 200
set pages 90

col sid                 form    999
col serial#             form    999999999
col username            form    a23
col status              form    a10 trunc
col total               form    999,999,999,999
col block_gets          form    999,999,999,999
col block_gets          form    999,999,999,999
col physical_reads      form    999,999,999,999
col block_changes       form    999,999,999,999
col consistent_changes  form    999,999,999,999
col consistent_gets     form    999,999,999,999
col consistent_reads    form    999,999,999,999

select
        io.SID,
        s.serial#,
        s.username,
        s.status,
        (io.block_gets+io.consistent_gets+io.physical_reads) total,
        io.BLOCK_GETS,
        io.CONSISTENT_GETS,
        io.PHYSICAL_READS,
        io.BLOCK_CHANGES,
        io.CONSISTENT_CHANGES
from v$sess_io io, v$session s
where io.sid=s.sid
and s.username is not null
and s.sid like nvl ( '&sid', '%')
order by total
/