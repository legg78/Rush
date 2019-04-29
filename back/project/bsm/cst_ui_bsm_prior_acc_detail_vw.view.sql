create or replace force view cst_ui_bsm_prior_acc_detail_vw as
  select a.id
    , a.file_date
    , a.customer_number
    , a.account_number
    , a.account_balance
    , a.customer_balance
    , a.agent_number
    , a.product_number
    , a.priority_flag
  from cst_bsm_prior_acc_detail_vw a
/
