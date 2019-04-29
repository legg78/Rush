create or replace force view app_ui_application_vw as
select a.id
     , a.seqnum
     , a.appl_type
     , a.appl_number
     , a.flow_id
     , com_api_i18n_pkg.get_text('app_flow', 'label', a.flow_id, l.lang) as flow_name
     , a.appl_status
     , a.reject_code
     , a.agent_id
     , a.inst_id
     , a.session_file_id
     , a.file_rec_num
     , a.resp_session_file_id
     , a.is_template
     , l.lang
     , null appl_description
     , (select min(change_date) from app_history h where h.appl_id = a.id and h.id between com_api_id_pkg.get_from_id(h.appl_id) and com_api_id_pkg.get_till_id(h.appl_id)) as created
     , (select max(change_date) from app_history h where h.appl_id = a.id and h.id between com_api_id_pkg.get_from_id(h.appl_id) and com_api_id_pkg.get_till_id(h.appl_id)) as last_updated
     , a.user_id
     , a.is_visible
     , a.appl_prioritized
     , a.execution_mode
  from app_application a
     , com_language_vw l
 where (a.appl_type = 'APTPINSA' or a.agent_id in (select agent_id from acm_cu_agent_vw))
   and a.is_template != 1
/
