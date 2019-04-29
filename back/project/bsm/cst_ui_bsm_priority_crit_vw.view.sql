create or replace force view cst_ui_bsm_priority_crit_vw as
    select a.application_id
         , a.seqnum
         , a.total_customer_balance
         , a.priority_flag
         , a.product_count
         , a.reissue_command
         , a.card_count
         , a.priority_appl_count
      from cst_bsm_priority_crit_vw a
/
