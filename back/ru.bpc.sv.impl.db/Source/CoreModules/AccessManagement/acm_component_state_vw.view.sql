create or replace force view acm_component_state_vw as
select id
     , user_id
     , component_id
     , state
  from acm_component_state
/