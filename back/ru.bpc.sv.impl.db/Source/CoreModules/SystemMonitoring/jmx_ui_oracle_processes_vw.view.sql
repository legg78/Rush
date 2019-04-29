create or replace force view jmx_ui_oracle_processes_vw as
select
       (
           select p.value
             from v$parameter p
            where p.name ='processes'
       ) as process_limit
     , (
           select count(1)
             from v$process
       ) as process_count
  from dual
/
