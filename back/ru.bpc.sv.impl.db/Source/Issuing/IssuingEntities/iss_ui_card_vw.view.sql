create or replace force view iss_ui_card_vw as
select c.id
     , c.split_hash
     , c.card_hash
     , c.card_mask
     , c.inst_id
     , c.card_type_id
     , c.country
     , c.customer_id
     , m.customer_number
     , c.cardholder_id
     , c.contract_id
     , c.reg_date
     , c.category
     , iss_api_token_pkg.decode_card_number(i_card_number => n.card_number) as card_number
     , t.contract_number
     , s.card_uid
  from iss_card c
     , iss_card_number n
     , prd_contract t
     , prd_customer m
     , iss_card_instance s
 where c.id = n.card_id
   and c.inst_id   in (select inst_id from acm_cu_inst_vw)
   and t.id         = c.contract_id
   and m.id         = c.customer_id
   and s.seq_number = (select max(seq_number) from iss_card_instance ii where ii.card_id = c.id)
   and c.id         = s.card_id
/
