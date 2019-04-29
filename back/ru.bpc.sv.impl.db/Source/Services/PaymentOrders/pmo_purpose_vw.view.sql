create or replace force view pmo_purpose_vw as
select a.id
     , a.provider_id
     , a.service_id
     , a.host_algorithm
     , a.oper_type
     , a.terminal_id
     , a.mcc
     , a.purpose_number
     , a.zero_order_status
     , a.mod_id
     , a.amount_algorithm
     , a.inst_id
  from pmo_purpose a
/
