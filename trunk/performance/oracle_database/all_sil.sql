--------------------------------------------------------------------------------
-- File name:   all_sil
-- Purpose:     Get Sessions In Lock
-- Author:      Claudio Moraes
-- Usage:       Run @all_sil
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on

select l1.sid, 'is blocking' "is blocking", l2.sid
from v$lock l1, v$lock l2
where l1.block = 1
  and l2.request > 0
  and l1.id1 = l2.id1
  and l1.id2 = l2.id2
/