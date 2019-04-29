create or replace force view pmo_api_order_vw as
select o.id
     , p.original_id
     , p.msg_type
     , o.status
     , o.split_hash
     , o.attempt_count
     , o.amount
     , o.currency
     , p.payment_host_id
  from pmo_order o
     , opr_operation p
 where o.id       = p.payment_order_id
   and p.msg_type = 'MSGTAUTH'
   and p.status   = 'OPST0400'
/
