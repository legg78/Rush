create or replace force view csm_ui_application_vw as
select a.id
     , a.seqnum
     , a.split_hash
     , a.appl_type
     , a.appl_number
     , a.flow_id
     , a.appl_status
     , a.reject_code
     , a.agent_id
     , a.inst_id
     , a.session_file_id
     , a.file_rec_num
     , a.resp_session_file_id
     , a.is_template
     , a.product_id
     , a.user_id
     , a.is_visible
     , c.case_source
  from app_application a
     , csm_application c
 where c.id(+) = a.id
/
