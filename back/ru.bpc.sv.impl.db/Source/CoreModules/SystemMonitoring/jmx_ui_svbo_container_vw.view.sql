create or replace force view jmx_ui_svbo_container_vw as
    select a.process_id as id
         , a.end_time as finish_time
         , a.result_code as state
         , get_text('prc_process', 'name', b.id, 'LANGENG') as name
      from prc_session  a
inner join prc_process_vw b
        on a.process_id = b.id
     where b.is_container = 1
       and a.parent_id is null
       and a.end_time = (
            select max(end_time)
              from prc_session_vw aa
             where aa.process_id = a.process_id
        )
  order by a.process_id
/
