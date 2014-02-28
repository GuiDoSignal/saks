--------------------------------------------------------------------------------
-- File name:   all_isid
-- Purpose:     Get useful information of given SIDs
-- Author:      Guilherme Botelho Diniz Junqueira
-- Usage:       Run @all_isid.sql and provide the SIDs
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on

column sid format 999999
column username format A15
column machine format A15
column program format A35
column hash_value format 9999999999
column sql_text format A65

select SID,
       SERIAL#,
       USERNAME,
	    STATUS,
	    OSUSER,
--	    MACHINE,
	    STATUS,
	    TYPE,
--	    SQL_HASH_VALUE,
       SQL_ID,
	    STATUS
from v$session
where sid in (&sid)
/