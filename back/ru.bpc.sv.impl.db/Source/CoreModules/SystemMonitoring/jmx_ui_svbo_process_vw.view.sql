create or replace force view jmx_ui_svbo_process_vw as
    with a as (
        select
               (
                   select to_char(min(nvl(c.parent_id, c.id)))
                     from prc_session c
                    where process_id is not null
               start with c.id = s.id
         connect by prior c.id = c.parent_id
               ) as container_session_id
             , s.*
          from prc_session s
         where s.id between com_api_id_pkg.get_from_id(sysdate - set_ui_value_pkg.get_system_param_n('JMX_MONITORING_SVBO_PROCESSES_PERIOD', 'DTTPNMBR'))
           and com_api_id_pkg.get_till_id(sysdate)
           and s.process_id is not null
           and s.parent_id is not null
    ), b as (
        select s.process_id as container_process_id
             , max(a.container_session_id) over (partition by s.process_id) as max_container_session_id
             , a.*
          from a
             , prc_session s
         where s.id = a.container_session_id
    )
    select
           (
               select c.id
                 from prc_container c
                where c.process_id = b.process_id
                  and c.container_process_id = b.container_process_id
           ) as id
         , b.process_id
         , get_text('prc_process', 'name', b.process_id, 'LANGENG') as name
         , b.container_process_id as container_id
         , get_text('prc_process', 'name', b.container_process_id, 'LANGENG') as container_name
         , b.result_code as state
         , b.estimated_count
         , b.processed
         , b.rejected
         , b.excepted
         , decode(b.estimated_count, 0, 0, b.processed / b.estimated_count * 100) as progress
         , decode(b.estimated_count, 0, 0, (b.estimated_count - b.processed) / b.estimated_count * 100) as remaining
         , b.start_time
         , b.end_time
      from b
     where b.container_session_id = b.max_container_session_id
  order by id
/
