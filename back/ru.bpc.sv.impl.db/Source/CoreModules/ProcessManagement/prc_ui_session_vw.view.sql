create or replace force view prc_ui_session_vw as
select
    a.id
  , a.process_id
  , a.parent_id
  , a.start_time
  , coalesce(a.end_time, (select max(case when s.current_count * s.estimated_count > 0 then s.start_time + (s.current_time - s.start_time) / s.current_count * s.estimated_count else s.start_time end) from prc_stat s where session_id = a.id)) end_time
  , a.processed
  , a.rejected
  , a.excepted
  , get_object_desc(i_entity_type => 'ENTTPERS', i_object_id => u.person_id) user_name
  , a.result_code
  , a.inst_id
  , b.procedure_name
  , get_text('prc_process', 'name', b.id, c.lang) process_name
  , b.is_container
  , c.lang
  , a.sttl_day
  , a.sttl_date
  , a.thread_count
  , a.estimated_count
  , a.ip_address
  , a.container_id
  , a.measure
from
    prc_session a
  , prc_process b
  , com_language_vw c
  , acm_user u
where a.process_id = b.id
  and u.id(+) = a.user_id
/
