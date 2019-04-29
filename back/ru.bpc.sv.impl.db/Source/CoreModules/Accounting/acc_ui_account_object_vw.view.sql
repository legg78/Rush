create or replace force view acc_ui_account_object_vw as
select o.id
     , a.account_type
     , a.account_number
     , a.currency
     , o.account_id
     , o.object_id
     , a.inst_id
     , a.agent_id
     , a.status
     , a.contract_id
     , a.contract_number
     , a.product_id
     , a.product_type
     , get_text('ost_institution', 'name', a.inst_id, l.lang) as inst_name
     , get_text('ost_agent', 'name', a.agent_id, l.lang) as agent_name
     , o.entity_type
     , o.split_hash
     , a.balance
     , a.customer_id
     , l.lang
     , o.is_pos_default
     , o.is_atm_default
     , o.is_atm_currency
     , o.is_pos_currency
     , o.account_seq_number
  from acc_ui_account_vw a
     , acc_account_object o
     , com_language_vw l
 where o.account_id = a.id
/
