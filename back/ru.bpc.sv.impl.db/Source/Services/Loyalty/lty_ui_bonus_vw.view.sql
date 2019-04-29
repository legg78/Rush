create or replace force view lty_ui_bonus_vw as
select b.id
     , b.account_id
     , b.card_id
     , b.product_id
     , b.service_id
     , b.oper_date
     , b.posting_date
     , b.start_date
     , b.expire_date
     , b.amount
     , b.spent_amount
     , b.status
     , b.inst_id
     , b.split_hash
     , a.customer_id
     , b.entity_type
     , b.object_id
     , b.fee_type
  from lty_bonus b
     , acc_account a
 where b.account_id = a.id
/
