create or replace force view acq_reimb_batch_vw as
select id
     , channel_id
     , pos_batch_id
     , oper_date
     , posting_date
     , sttl_day
     , reimb_date
     , merchant_id
     , cheque_number
     , status
     , gross_amount
     , service_charge
     , tax_amount
     , net_amount
     , oper_count
     , inst_id
     , split_hash
     , account_id
     , session_file_id
     , seqnum
  from acq_reimb_batch
/
