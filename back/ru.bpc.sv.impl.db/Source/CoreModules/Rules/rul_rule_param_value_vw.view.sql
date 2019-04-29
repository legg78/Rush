create or replace force view rul_rule_param_value_vw as
select id
     , seqnum
     , rule_id
     , proc_param_id
     , param_value
  from rul_rule_param_value
/