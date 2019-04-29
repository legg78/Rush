create or replace force view acc_account_vw as
select a.id
     , a.account_type
     , a.account_number
     , a.currency
     , a.inst_id
     , a.agent_id
     , a.status
     , a.contract_id
     , a.customer_id
     , a.split_hash
     , a.scheme_id
  from acc_account a
/
