create or replace force view frp_ui_fraud_data_vw as
select o.auth_id
     , o.entity_type
     , o.object_id
     , a.split_hash
     , a.msg_type 
     , a.oper_date
     , c.card_number
     , a.merchant_number
     , a.terminal_number
     , f.event_type
     , o.serial_number
     , a.oper_amount
     , a.oper_currency
     , f.case_id
  from frp_fraud f
     , frp_auth a
     , frp_auth_object o
     , frp_auth_card c
 where f.auth_id = a.id
   and o.auth_id = a.id
   and c.id      = a.id
/

