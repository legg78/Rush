create table cst_mpu_fin_msg (
    id                    number(16)
  , split_hash            number(4)
  , inst_id               number(4)
  , network_id            number(4)
  , is_incoming           number(1)
  , is_reversal           number(1)
  , is_matched            number(1)
  , status                varchar2(8)
  , file_id               number(16) 
  , dispute_id            number(16) 
  , original_id           number(16) 
  , message_number        number(8)  
  , record_type           varchar2(3)  
  , card_mask             varchar2(19)
  , proc_code             varchar2(6) 
  , trans_amount          number(12)  
  , sttl_amount           number(12) 
  , sttl_rate             number(8)  
  , sys_trace_num         varchar2(6) 
  , trans_date            date 
  , sttl_date             varchar2(4) 
  , mcc                   varchar2(4) 
  , acq_inst_code         varchar2(11) 
  , iss_bank_code         varchar2(11)
  , bnb_bank_code         varchar2(11) 
  , forw_inst_code        varchar2(11) 
  , receiv_inst_code      varchar2(11)
  , auth_number           varchar2(6)  
  , rrn                   varchar2(12) 
  , terminal_number       varchar2(8)  
  , trans_currency        varchar2(3)  
  , sttl_currency         varchar2(3)  
  , acct_from             varchar2(28) 
  , acct_to               varchar2(28) 
  , mti                   varchar2(4) 
  , trans_status          number(4) 
  , service_fee_receiv    number(12) 
  , service_fee_pay       number(12) 
  , service_fee_interchg  number(12) 
  , pos_entry_mode        varchar2(3)  
  , sys_trace_num_orig    varchar2(6)  
  , pos_cond_code         varchar2(2)  
  , merchant_number       varchar2(15) 
  , merchant_name         varchar2(40)
  , accept_amount         number(12) 
  , cardholder_trans_fee  number(12) 
  , transmit_date         date 
  , orig_trans_info       varchar2(23)
  , trans_features        varchar2(1) 
  , merchant_country      varchar2(3)
  , auth_type             varchar2(3)
  , reason_code           varchar2(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/

comment on table cst_mpu_fin_msg is 'MPU financial messages'
/
comment on column cst_mpu_fin_msg.id is 'Primary key. Message identifier'
/
comment on column cst_mpu_fin_msg.split_hash is 'Institution identifier'
/
comment on column cst_mpu_fin_msg.inst_id is 'Institution identifier'
/
comment on column cst_mpu_fin_msg.network_id is 'Network identifier'
/
comment on column cst_mpu_fin_msg.is_incoming is 'Incoming indicator'
/
comment on column cst_mpu_fin_msg.is_reversal is 'Reversal indicator'
/
comment on column cst_mpu_fin_msg.is_matched is 'Matched indicator'
/
comment on column cst_mpu_fin_msg.status is 'Message status'
/
comment on column cst_mpu_fin_msg.file_id is 'File identifier'
/
comment on column cst_mpu_fin_msg.dispute_id is 'Dispute identifier'
/
comment on column cst_mpu_fin_msg.original_id is 'Reference to original operation'
/
comment on column cst_mpu_fin_msg.message_number is 'Message number'
/
comment on column cst_mpu_fin_msg.record_type is 'Record Type'
/
comment on column cst_mpu_fin_msg.card_mask is 'Card mask'
/
comment on column cst_mpu_fin_msg.proc_code is 'Processing Code (F3)'
/ 
comment on column cst_mpu_fin_msg.trans_amount is 'Amount, Transaction (F4)'
/ 
comment on column cst_mpu_fin_msg.sttl_amount is 'Amount, Settlement'
/
comment on column cst_mpu_fin_msg.sttl_rate is 'Sett conversion rate'
/
comment on column cst_mpu_fin_msg.sys_trace_num is 'System trace number (F11)'
/ 
comment on column cst_mpu_fin_msg.trans_date is 'Local transaction date and time (F13) (F12)'
/ 
comment on column cst_mpu_fin_msg.sttl_date is 'Settlement date (F15)'
/ 
comment on column cst_mpu_fin_msg.mcc is 'Terminal type (F18)'
/ 
comment on column cst_mpu_fin_msg.acq_inst_code is 'Acquiring Institution Code(F32)'
/ 
comment on column cst_mpu_fin_msg.iss_bank_code is 'Issuer bank code/Issuing institution identification code'
/
comment on column cst_mpu_fin_msg.bnb_bank_code is 'Beneficiary bank code (F100)'
/ 
comment on column cst_mpu_fin_msg.forw_inst_code is 'Forwarding Institution Code (F33)'
/ 
comment on column cst_mpu_fin_msg.receiv_inst_code is 'Receiving institution identification code (F100)'
/
comment on column cst_mpu_fin_msg.auth_number is 'Authorization Number (F38)'
/ 
comment on column cst_mpu_fin_msg.rrn is 'Retrieval Reference  number (F37)'
/ 
comment on column cst_mpu_fin_msg.terminal_number is 'Card Acceptor Terminal Identification (F41)'
/ 
comment on column cst_mpu_fin_msg.trans_currency is 'Transaction currency code (F49)'
/ 
comment on column cst_mpu_fin_msg.sttl_currency is 'Settlement Currency code'
/ 
comment on column cst_mpu_fin_msg.acct_from is 'From Account (F102)'
/ 
comment on column cst_mpu_fin_msg.acct_to is 'To Account (F103)'
/ 
comment on column cst_mpu_fin_msg.mti is 'Message Type Identifier Code (MTI)'
/ 
comment on column cst_mpu_fin_msg.trans_status is 'Transaction status (Response Code)'
/ 
comment on column cst_mpu_fin_msg.service_fee_receiv is 'Service Fee Receivable'
/ 
comment on column cst_mpu_fin_msg.service_fee_pay is 'Service Fee Payable'
/ 
comment on column cst_mpu_fin_msg.service_fee_interchg is 'Interchange Service Fee'
/ 
comment on column cst_mpu_fin_msg.pos_entry_mode is 'Point of Service Entry Mode (F22)'
/ 
comment on column cst_mpu_fin_msg.sys_trace_num_orig is 'System Trace Number of Original Transaction (F90.2)'
/ 
comment on column cst_mpu_fin_msg.pos_cond_code is 'Point of Service Condition Code (F25)'
/ 
comment on column cst_mpu_fin_msg.merchant_number is 'Card Acceptor Identification Code (F42)'
/ 
comment on column cst_mpu_fin_msg.merchant_name is 'Card acceptor name/location (F43)'
/
comment on column cst_mpu_fin_msg.accept_amount is 'Acceptance Amount in Part of Collection (F95)'
/ 
comment on column cst_mpu_fin_msg.cardholder_trans_fee is 'Cardholder Transaction Fee (F28)'
/ 
comment on column cst_mpu_fin_msg.transmit_date is 'Transaction Transmission Date/Time (F7)'
/ 
comment on column cst_mpu_fin_msg.orig_trans_info is 'Original transaction information'
/
comment on column cst_mpu_fin_msg.trans_features is 'Identifier of Transaction Features'
/
comment on column cst_mpu_fin_msg.merchant_country is 'Merchant Country Code (F19)'
/
comment on column cst_mpu_fin_msg.auth_type is 'Authorization Type'
/
comment on column cst_mpu_fin_msg.reason_code is 'Message reason code'
/

