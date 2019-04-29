create or replace force view ost_ui_agent_vw as
select a.id
     , a.seqnum
     , a.inst_id
     , a.parent_id
     , a.agent_type
     , a.is_default
     , get_text('ost_agent', 'name', a.id, b.lang) name
     , get_text('ost_agent', 'description', a.id, b.lang) description
     , b.lang
     , agent_number
  from ost_agent a
     , com_language_vw b
 where a.id in (select agent_id from acm_cu_agent_vw)
/