--------------------------------------------------------------------------------
-- File name:   plansForHashValue.sql
--
-- Purpose:     Get the hash values of the plans used for the given SQL ID (hash value).
--				The plans are searched only in the interval between initial_date and final_date
-- Author:      Guilherme Botelho Diniz Junqueira
-- Usage:       Run @plansForHashValue and provide the hash_value and the dates
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000

select  pu.plan_hash_value,
        to_char(ss.snap_time, 'dd/mm/rr hh24:mi') as "snap_time",
        ss.snap_id,
from    stats$sql_plan_usage pu,
        stats$snapshot ss
where   pu.dbid = ss.dbid
  and   pu.instance_number = ss.instance_number
  and   pu.snap_id = ss.snap_id
  and   pu.hash_value = :hash_value
  and   ss.snap_time >= to_date(:initial_date, 'dd/mm/rr hh24:mi')
  and   ss.snap_time < to_date(:final_date, 'dd/mm/rr hh24:mi')
order by ss.snap_time
/