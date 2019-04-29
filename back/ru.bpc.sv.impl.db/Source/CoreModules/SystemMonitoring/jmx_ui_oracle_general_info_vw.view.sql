create or replace force view jmx_ui_oracle_general_info_vw as
select t.version
     , t.uptime
     , t.archive_log
     , t.latch_misses
from (
    select
           (
               select (v.version || ' (' || (listagg(v.product, ',') within group (order by v.product)) || ')')
                 from product_component_version v
             group by v.version
           ) as version
         , (
               select round((sysdate - startup_time) * 86400)
                 from v$instance
           ) as uptime
         , (
               select round((t1.logs * t1.avg) / 10 / 1024 / 1024)
                 from (
                   select
                          (
                           select count(1) logs
                             from v$log_history
                            where first_time >= (sysdate - 10/24/60)
                          ) logs -- logs for the last 10 minutes
                        , (
                           select avg(bytes) as avg
                             from v$log
                          ) avg
                     from dual
                 ) t1
           ) as archive_log
         , (
              select sum(misses)
                from v$latch
           ) as latch_misses
      from dual
) t
/
