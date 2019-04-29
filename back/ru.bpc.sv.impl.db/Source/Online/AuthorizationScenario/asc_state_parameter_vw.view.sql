create or replace force view asc_state_parameter_vw as
select id
     , seqnum
     , state_type
     , param_id
     , default_value
     , display_order
  from asc_state_parameter
/