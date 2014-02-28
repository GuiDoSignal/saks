column "Operation" format A40
column "Object Name" format A30
column "PStart" format A6
column "PStop" format A6
column "I" format A3
column ACCESS_PREDICATES format A80
column FILTER_PREDICATES format A80
set lines 9999
set pages 99
set trimspool on
set verify off
set heading on

select  /*+ NO_MERGE */ rownum  ||
decode(access_predicates,NULL,decode(filter_predicates,NULL,'','*'),'*') "I",
        substr(lpad(' ',2*(depth-1)) || operation,1,20) ||
        decode(options,NULL,'',' (' || options || ')') "Operation",
        substr(object_name,1,30) "Object Name",
        cardinality "# Rows",
        bytes,
        cost,
        partition_start "PStart",
        partition_stop "PStop"
  from (select * from v$sql_plan where hash_value = &&hash_value) a
  start with id = 0
  connect by prior id = parent_id
      and prior nvl(hash_value, 0 ) = nvl(hash_value, 0 )
  order by id, position
/
set heading off
select 'Access Predicates .....' from dual;
select * from (
select  /*+ NO_MERGE */ rownum  ||
decode(access_predicates,NULL,decode(filter_predicates,NULL,'','*'),'*') "I",
    decode(access_predicates,NULL,'###',access_predicates) "ACCESS_PREDICATES"
  from (select * from v$sql_plan where hash_value = &hash_value) a
  start with id = 0
  connect by prior id = parent_id
      and prior nvl(hash_value, 0 ) = nvl(hash_value, 0 )
  order by id, position
) where access_predicates <> '###'
/
set heading off
select 'Filter predicates .....' from dual;
select * from (
select  /*+ NO_MERGE */ rownum  ||
decode(access_predicates,NULL,decode(filter_predicates,NULL,'','*'),'*') "I",
    decode(filter_predicates,NULL,'###',filter_predicates) "FILTER_PREDICATES"
  from (select * from v$sql_plan where hash_value = &&hash_value) a
  start with id = 0
  connect by prior id = parent_id
      and prior nvl(hash_value, 0 ) = nvl(hash_value, 0 )
  order by id, position
) where filter_predicates <> '###'
/
set heading on
undef hash_value