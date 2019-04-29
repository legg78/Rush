create or replace force view iss_card_vw as
select c.id
     , c.split_hash
     , c.card_hash
     , c.card_mask
     , c.inst_id
     , c.card_type_id
     , c.country
     , c.customer_id
     , c.cardholder_id
     , c.contract_id
     , c.reg_date
     , c.category
     , n.card_number
  from iss_card c
     , iss_card_number n
 where c.id = n.card_id
/