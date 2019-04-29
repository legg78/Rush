create or replace force view cst_ui_mpu_fin_msg_vw as
select m.id
     , m.inst_id
     , ost_ui_institution_pkg.get_inst_name(i_inst_id => m.inst_id, i_lang => l.lang) inst_name
     , m.network_id
     , m.is_incoming
     , m.is_reversal
     , m.is_matched
     , m.status
     , m.file_id
     , m.dispute_id
     , m.original_id
     , m.message_number
     , m.record_type
     , m.card_mask
     , m.proc_code
     , m.trans_amount
     , m.sttl_amount
     , m.sttl_rate
     , m.sys_trace_num
     , m.trans_date
     , m.sttl_date
     , m.mcc
     , m.acq_inst_code
     , m.iss_bank_code
     , m.bnb_bank_code
     , m.forw_inst_code
     , m.receiv_inst_code
     , m.auth_number
     , m.rrn
     , m.terminal_number
     , m.trans_currency
     , m.sttl_currency
     , m.acct_from
     , m.acct_to
     , m.mti
     , m.trans_status
     , m.service_fee_receiv
     , m.service_fee_pay
     , m.service_fee_interchg
     , m.pos_entry_mode
     , m.sys_trace_num_orig
     , m.pos_cond_code
     , m.merchant_number
     , m.merchant_name
     , m.accept_amount
     , m.cardholder_trans_fee
     , m.transmit_date
     , m.orig_trans_info
     , m.trans_features
     , m.merchant_country
     , m.auth_type
     , m.reason_code
     , l.lang
  from cst_mpu_fin_msg m
     , com_language_vw l
/
