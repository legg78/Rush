create or replace force view prc_api_active_session_vw as
select a.id as session_id
     , a.parent_id parent_session_id
     , a.process_id
     , a.start_time
     , u.name user_name
     , a.inst_id
     , a.sttl_date
     , a.thread_count
     , a.estimated_count
     , b.procedure_name
     , b.name as procedure_label
     , b.is_parallel
     , b.is_external
     , b.is_container
  from prc_session a
     , prc_ui_process_vw b
     , acm_user u
 where a.process_id = b.id
   and a.end_time is null
   and a.result_code = 'PRSR0001'
   and a.start_time >= sysdate-1
   and a.user_id = u.id
/
