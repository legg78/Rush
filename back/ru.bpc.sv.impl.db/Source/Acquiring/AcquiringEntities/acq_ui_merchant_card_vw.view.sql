create or replace force view acq_ui_merchant_card_vw as
select m.object_id          as merchant_id
     , get_text(
           'acq_merchant'
         , 'label'
         , m.object_id
         , l.lang)          as merchant_name
     , ac.inst_id           as inst_id
     , get_text(
           'ost_institution'
         , 'name'
         , ac.inst_id
         , l.lang
       )                    as inst_name
     , cn.product_id        as product_id
     , get_text(
           'prd_product'
         , 'label'
         , cn.product_id
         , l.lang
       )                    as product_name
     , ac.id                as account_id
     , ac.account_number    as account_number
     , c.cardholder_id      as cardholder_id
     , ch.cardholder_name   as cardholder_name
     , c.card_type_id       as card_type_id
     , get_text(
           'net_card_type'
         , 'name'
         , c.card_type_id
         , l.lang
       )                    as card_type_name
     , a.object_id          as card_uid
     , c.card_mask          as card_mask
     , c.reg_date           as reg_date
     , l.lang               as lang
  from acc_account_object m
     , acc_account_object a
     , acc_account ac
     , iss_card c
     , iss_cardholder ch
     , prd_contract cn
     , com_language_vw l
 where m.account_id     = ac.id
   and a.account_id     = ac.id
   and m.entity_type    = 'ENTTMRCH'
   and a.entity_type    = 'ENTTCARD'
   and a.object_id      = c.id
   and ac.contract_id   = cn.id
   and c.cardholder_id  = ch.id
   and ac.inst_id       in (select inst_id from acm_cu_inst_vw)
/
