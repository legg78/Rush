create or replace force view acm_ui_action_vw as 
select a.id
     , a.seqnum
     , a.call_mode
     , a.entity_type
     , a.object_type
     , a.group_id
     , a.section_id
     , a.priv_id
     , a.priv_object_id
     , a.inst_id
     , a.is_default
     , a.object_type_lov_id
     , get_text('acm_action', 'label', a.id, b.lang) as label
     , get_text('acm_action', 'description', a.id, b.lang) as description
     , b.lang
  from acm_action a
     , com_language_vw b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
/

