create or replace force view lty_bonus_vw as
select id
     , account_id
     , card_id
     , product_id
     , service_id
     , oper_date
     , posting_date
     , start_date
     , expire_date
     , amount
     , spent_amount
     , status
     , inst_id
     , split_hash
     , entity_type
     , object_id
     , fee_type
  from lty_bonus c
/
