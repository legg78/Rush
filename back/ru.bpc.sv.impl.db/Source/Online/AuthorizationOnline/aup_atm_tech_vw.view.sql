create or replace force view aup_atm_tech_vw as
select terminal_id
     , time_mark
     , tech_id
     , message_type
     , last_oper_id 
  from aup_atm_tech
/
