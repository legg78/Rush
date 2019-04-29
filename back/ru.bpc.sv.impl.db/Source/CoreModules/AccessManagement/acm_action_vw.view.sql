create or replace force view acm_action_vw as 
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
from acm_action a
/
