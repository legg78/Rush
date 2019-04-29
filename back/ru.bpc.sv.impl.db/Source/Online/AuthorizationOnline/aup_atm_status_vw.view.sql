create or replace force view aup_atm_status_vw as
select id
     , tech_id
     , time_mark
     , device_id
     , device_status
     , error_severity
     , diag_status
     , supplies_status
  from aup_atm_status
/
