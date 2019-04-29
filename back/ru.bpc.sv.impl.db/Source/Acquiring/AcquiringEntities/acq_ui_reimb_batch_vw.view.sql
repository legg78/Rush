create or replace force view acq_ui_reimb_batch_vw as
select a.id
     , a.channel_id
     , a.pos_batch_id
     , a.oper_date
     , a.posting_date
     , a.sttl_day
     , a.reimb_date
     , a.merchant_id
     , a.cheque_number
     , a.status
     , a.gross_amount
     , a.service_charge
     , a.tax_amount
     , a.net_amount
     , a.oper_count
     , a.inst_id
     , a.split_hash
     , a.account_id
     , a.session_file_id
     , a.seqnum
     , b.currency
     , b.account_number
     , c.merchant_number
     , c.merchant_name
     , c.risk_indicator
  from acq_reimb_batch a
     , acc_account b
     , acq_merchant c
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
   and a.account_id = b.id
   and a.merchant_id = c.id
/
