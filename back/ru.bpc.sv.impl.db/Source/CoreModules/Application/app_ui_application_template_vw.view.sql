create or replace force view app_ui_application_template_vw as
select a.id
     , a.seqnum
     , a.appl_type
     , a.flow_id
     , com_api_i18n_pkg.get_text('app_flow', 'label', a.flow_id, l.lang) as flow_name
     , a.agent_id
     , a.inst_id
     , a.product_id
     , l.lang
  from app_application a
     , com_language_vw l
 where a.agent_id in (select agent_id from acm_cu_agent_vw)
   and a.is_template = 1
/
