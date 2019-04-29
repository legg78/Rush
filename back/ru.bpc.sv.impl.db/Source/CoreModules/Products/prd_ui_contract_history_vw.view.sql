create or replace force view prd_ui_contract_history_vw as
select contract_id
     , product_id
     , start_date
     , end_date
     , split_hash
  from prd_contract_history
/