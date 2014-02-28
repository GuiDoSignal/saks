--------------------------------------------------------------------------------
-- File name:   all_st4h.sql
--
-- Purpose:     Get the Sql Text for the given Hash value
-- Author:      Guilherme Botelho Diniz Junqueira
-- Usage:       Run @all_st4h.sql and provide the hash_values
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on
column hash_value format 9999999999
column sql_text format A100

select s.hash_value,
       s.sql_text
from v$sqltext s
where s.hash_value in (&hash_value)
order by s.piece
/