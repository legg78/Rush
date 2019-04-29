create or replace force view svy_qstn_parameter_value_vw as
select pv.id
     , pv.seqnum
     , pv.questionary_id
     , pv.param_id
     , pv.param_value
     , pv.seq_number
  from svy_qstn_parameter_value pv
/
