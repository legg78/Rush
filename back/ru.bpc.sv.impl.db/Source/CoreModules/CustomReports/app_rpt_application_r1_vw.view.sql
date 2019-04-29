create or replace force view app_rpt_application_r1_vw as
select id
     , split_hash
     , seqnum
     , appl_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => appl_type
       ) appl_type_name
     , appl_number
     , flow_id
     , appl_status
     , com_api_dictionary_pkg.get_article_text(
           i_article => appl_status
       )appl_status_name
     , reject_code
     , com_api_dictionary_pkg.get_article_text(
           i_article => reject_code
       ) reject_code_name
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
  from app_application
/

