create or replace force view bgn_ui_no_file_vw as
select  f.id
      , s.file_name
      , f.bank_name
      , f.sttl_acc_number
      , f.sttl_date
      , f.sttl_ref
      , f.swift_msg_number
      , f.sttl_currency
      , f.ttt_debit_count
      , f.ttt_debit_trans
      , f.ttt_debit_tax
      , f.ttt_debit_total
      , f.ttt_credit_count
      , f.ttt_credit_trans
      , f.ttt_credit_tax
      , f.ttt_credit_total
      , f.total_amount
  from  bgn_no_file f
      , prc_session_file s
 where f.id = s.id
/
 