create or replace force view app_application_vw as
select id
     , seqnum
     , split_hash
     , appl_type
     , appl_number
     , flow_id
     , appl_status
     , reject_code
     , agent_id
     , inst_id
     , session_file_id
     , file_rec_num
     , resp_session_file_id
     , is_template
     , product_id
     , user_id
     , is_visible
     , appl_prioritized
     , execution_mode
  from app_application
/
