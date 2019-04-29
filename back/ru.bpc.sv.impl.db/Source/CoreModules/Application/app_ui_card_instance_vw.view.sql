create or replace force view app_ui_card_instance_vw as
select i.id
     , a.id as appl_id
     , a.flow_id
     , com_api_i18n_pkg.get_text('app_flow', 'label', a.flow_id, l.lang) as flow_name
     , a.appl_status
     , l.lang
     , (select min(change_date) from app_history h where h.appl_id = a.id and h.id between com_api_id_pkg.get_from_id(h.appl_id) and com_api_id_pkg.get_till_id(h.appl_id)) as creation_date
     , (select max(change_date) from app_history h where h.appl_id = a.id and h.id between com_api_id_pkg.get_from_id(h.appl_id) and com_api_id_pkg.get_till_id(h.appl_id)) as processing_date
  from app_application a
     , com_language_vw l
     , app_object o
     , iss_card c
     , iss_card_instance i
 where a.agent_id in (select agent_id from acm_cu_agent_vw)
   and o.entity_type = 'ENTTCARD'
   and o.appl_id = a.id
   and o.object_id = c.id
   and c.id = i.card_id
/
