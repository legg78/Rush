create or replace force view svy_param_entity_vw as
select e.id
     , e.seqnum
     , e.entity_type
     , e.param_id
  from svy_parameter_entity e
/
