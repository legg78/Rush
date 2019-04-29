create or replace force view acq_ui_reimb_oper_vw as
select a.id
     , a.batch_id
     , a.channel_id
     , a.pos_batch_id
     , a.oper_date
     , a.posting_date
     , a.sttl_day
     , a.reimb_date
     , a.account_id
     , a.merchant_id
     , a.gross_amount
     , a.service_charge
     , a.tax_amount
     , a.net_amount
     , a.inst_id
     , a.split_hash
     , b.currency
  from acq_reimb_oper a
     , acc_account b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
   and a.account_id = b.id
/
