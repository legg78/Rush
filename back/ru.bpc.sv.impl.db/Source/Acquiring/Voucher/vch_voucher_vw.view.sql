create or replace force view vch_voucher_vw as
select id
     , seqnum
     , batch_id
     , card_id
     , expir_date
     , oper_amount
     , oper_id
     , oper_type
     , auth_code
     , oper_request_amount
     , oper_date
  from vch_voucher
/