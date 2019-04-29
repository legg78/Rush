create or replace force view pmo_api_terminal_value_vw as
select a.id
     , a.purp_param_id
     , b.purpose_id
     , b.param_id
     , a.entity_type
     , a.object_id
     , a.param_value
  from pmo_purp_param_value a
     , pmo_purpose_parameter b
 where a.entity_type = 'ENTTTRMN'
   and a.purp_param_id = b.id 
/
