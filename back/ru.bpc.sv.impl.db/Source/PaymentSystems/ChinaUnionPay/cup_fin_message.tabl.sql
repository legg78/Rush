
create table cup_fin_message
(
  id                           number(16) not null,
  status                       varchar2(8),
  is_reversal                  number(1),
  is_incoming                  number(1),
  is_rejected                  number(1),
  is_invalid                   number(1),
  inst_id                      number(4),
  network_id                   number(4),
  host_inst_id                 number(4),
  collect_only_flag            varchar2(1),
  rrn                          varchar2(255) not null,
  acceptor_id_code             varchar2(255),
  agency_id                    varchar2(255),
  amt_tran                     number(19),
  app_version_no               varchar2(255),
  appl_charact                 varchar2(255),
  appl_crypt                   varchar2(255),
  auth_amount                  number(19),
  auth_method                  varchar2(255),
  auth_resp_id                 varchar2(255),
  cap_of_term                  varchar2(255),
  card_serial_num              number(10),
  cipher_text_inf_data         varchar2(255),
  code_of_trans_currency       number(10),
  country_code_of_term         varchar2(255),
  dedic_doc_name               varchar2(255),
  ic_card_cond_code            varchar2(255),
  interface_serial             varchar2(255),
  iss_bank_app_data            varchar2(255),
  local                        number(1),
  mcc                          number(10),
  mrc_name                     varchar2(255),
  other_amount                 number(19),
  point                        varchar2(255),
  proc_func_code               varchar2(255),
  read_cap_of_term             varchar2(255),
  result_term_verif            varchar2(255),
  reversal                     number(1),
  script_result_of_card_issuer varchar2(255),
  sending_inst_id              varchar2(255),
  serv_input_mode_code         number(10),
  sys_trace_num                number(19),
  term_cat                     varchar2(255),
  term_id                      varchar2(255),
  tran_curr_code               varchar2(255),
  tran_init_channel            number(10),
  trans_cat                    number(10),
  trans_cnt                    varchar2(255),
  trans_date                   varchar2(255),
  trans_resp_code              varchar2(255),
  trans_serial_cnt             varchar2(255),
  trans_type                   number(10),
  transmission_date_time       timestamp(6),
  unpred_num                   varchar2(255)
)
/

comment on column cup_fin_message.id is 'Primary key. Message identifier'
/
comment on column cup_fin_message.status is 'Status messages'
/
comment on column cup_fin_message.is_reversal is 'Reversal indicator'
/
comment on column cup_fin_message.is_incoming is '0 - incoming file, 1 � outgoing file'
/
comment on column cup_fin_message.is_rejected is 'Rejected indicator'
/
comment on column cup_fin_message.is_invalid is '1 � invalid message'
/
comment on column cup_fin_message.inst_id is 'Institution identifier'
/
comment on column cup_fin_message.network_id is 'Network identifier'
/
comment on column cup_fin_message.host_inst_id is 'Host institution identifier'
/
comment on column cup_fin_message.collect_only_flag is 'Collection-only flag'
/
alter table cup_fin_message add (file_id number(16))
/
comment on column cup_fin_message.file_id is 'Reference to clearing file'
/
alter table cup_fin_message add (msg_number number(8))
/
comment on column cup_fin_message.msg_number is 'Message Number'
/
alter table cup_fin_message add (bill_exch_rate          number(19))
/
alter table cup_fin_message add (cardholder_acc_currency varchar2(255))
/
alter table cup_fin_message add (cardholder_bill_amount  number(19))
/
alter table cup_fin_message add (cups_notice             number(10))
/
alter table cup_fin_message add (cups_ref_num            varchar2(255))
/
alter table cup_fin_message add (double_message_id       number(1))
/
alter table cup_fin_message add (int_org                 varchar2(255))
/
alter table cup_fin_message add (issue                   number(1))
/
alter table cup_fin_message add (issue_code              varchar2(255))
/
alter table cup_fin_message add (orig_trans_data         varchar2(255))
/
alter table cup_fin_message add (payment_service_type    varchar2(255))
/
alter table cup_fin_message add (pos_input_mode          varchar2(255))
/
alter table cup_fin_message add (reason_code             varchar2(255))
/
alter table cup_fin_message add (receive_inst_id         varchar2(255))
/
alter table cup_fin_message add (service_fee_amount      varchar2(255))
/
alter table cup_fin_message add (service_fee_currency    varchar2(255))
/
alter table cup_fin_message add (service_fee_exch_rate   number(19))
/
alter table cup_fin_message add (settlement_exch_rate    number(19))
/
alter table cup_fin_message add (terminal_auth_date      timestamp(6))
/
alter table cup_fin_message add (trans_features_id       varchar2(255))
/
alter table cup_fin_message add (transferred             number(1))
/
alter table cup_fin_message add (ic_trans_currency_code  varchar2(255))
/
alter table cup_fin_message add (ic_pos_input_mode       varchar2(255))
/
alter table cup_fin_message drop column reversal
/
alter table cup_fin_message add (original_id number(16))
/
comment on column cup_fin_message.original_id is 'Reference to original operation in case of reversal'
/
alter table cup_fin_message add (merchant_country varchar2(3))
/
comment on column cup_fin_message.merchant_country is 'Merchant country code'
/
alter table cup_fin_message add (pos_cond_code varchar2(2))
/
comment on column cup_fin_message.pos_cond_code is 'POS condition code'
/
alter table cup_fin_message rename column trans_type to trans_code
/
comment on column cup_fin_message.trans_code is 'Transaction code'
/
alter table cup_fin_message add (orig_trans_code number(10))
/
comment on column cup_fin_message.orig_trans_code is 'Transaction code of original financial message'
/
alter table cup_fin_message add (orig_sys_trace_num number(19))
/
comment on column cup_fin_message.orig_sys_trace_num is 'System audit trace number of original financial message'
/
alter table cup_fin_message add (orig_trans_date date)
/
comment on column cup_fin_message.orig_trans_date is 'Settlement date of original transaction'
/
alter table cup_fin_message add (orig_transmission_date_time date)
/
comment on column cup_fin_message.orig_transmission_date_time is 'Transmission date and time of original financial message'
/
comment on column cup_fin_message.rrn is 'Retrieval Reference Number'
/
comment on column cup_fin_message.acceptor_id_code is 'Card acceptor identification code'
/
comment on column cup_fin_message.agency_id is 'Acquiring Institution Identification Number'
/
comment on column cup_fin_message.amt_tran is 'Transaction amount'
/
comment on column cup_fin_message.app_version_no is 'Application version No'
/
comment on column cup_fin_message.appl_charact is 'Application Alternation Characteristic'
/
comment on column cup_fin_message.appl_crypt is 'Applied Cryptogram'
/
comment on column cup_fin_message.auth_amount is 'Authorized amount'
/
comment on column cup_fin_message.auth_method is 'Authentication method and result of the cardholder'
/
comment on column cup_fin_message.auth_resp_id is 'Authorization identification response'
/
comment on column cup_fin_message.cap_of_term is 'Terminal capabilities'
/
comment on column cup_fin_message.card_serial_num is 'Application PAN sequence number'
/
comment on column cup_fin_message.cipher_text_inf_data is 'Cipher text information data'
/
comment on column cup_fin_message.code_of_trans_currency is 'Authorized currency code'
/
comment on column cup_fin_message.country_code_of_term is 'Country code of the terminal'
/
comment on column cup_fin_message.dedic_doc_name is 'Dedicated document name'
/
comment on column cup_fin_message.ic_card_cond_code is 'IC Card Condition Code'
/
comment on column cup_fin_message.interface_serial is 'Serial Number Of Interface Device'
/
comment on column cup_fin_message.iss_bank_app_data is 'Issuing Bank Application Data'
/
comment on column cup_fin_message.mcc is 'Merchant''s Type'
/
comment on column cup_fin_message.mrc_name is 'Card acceptor name/location'
/
comment on column cup_fin_message.other_amount is 'Other amount'
/
comment on column cup_fin_message.read_cap_of_term is 'Terminal entry capability'
/
comment on column cup_fin_message.result_term_verif is 'Terminal verification results'
/
comment on column cup_fin_message.script_result_of_card_issuer is 'Script result of card issuer'
/
comment on column cup_fin_message.sending_inst_id is 'Forwarding institution identification code'
/
comment on column cup_fin_message.serv_input_mode_code is 'Point of service entry mode'
/
comment on column cup_fin_message.sys_trace_num is 'System trace audit number'
/
comment on column cup_fin_message.term_cat is 'Terminal category'
/
comment on column cup_fin_message.term_id is 'Card acceptor terminal identification'
/
comment on column cup_fin_message.tran_curr_code is 'Transaction currency code'
/
comment on column cup_fin_message.tran_init_channel is 'Transaction initiating channel'
/
comment on column cup_fin_message.trans_cat is 'Transaction category'
/
comment on column cup_fin_message.trans_cnt is 'Application Transaction Counter'
/
comment on column cup_fin_message.trans_date is 'Date of authorization. Format is mmdd'
/
comment on column cup_fin_message.trans_resp_code is 'Transaction response code'
/
comment on column cup_fin_message.trans_serial_cnt is 'Transaction serial counter'
/
comment on column cup_fin_message.transmission_date_time is 'Transmission date and time. Format is mmddhh24mmss'
/
comment on column cup_fin_message.unpred_num is 'Unpredictable Number'
/
comment on column cup_fin_message.terminal_auth_date is 'Transaction Date. Format is yymmdd'
/
comment on column cup_fin_message.pos_cond_code is 'Point of service condition code'
/
comment on column cup_fin_message.reason_code is 'Message reason code'
/
comment on column cup_fin_message.double_message_id is 'Single or dual message identifier. 0 - single message, 1 - dual message'
/
comment on column cup_fin_message.cups_ref_num is 'CUPS serial Number'
/
comment on column cup_fin_message.receive_inst_id is 'Receiving institution identification code'
/
comment on column cup_fin_message.issue_code is 'Issuing institution identification code'
/
comment on column cup_fin_message.cups_notice is 'Identifier of CUPS Notice. 0 - normal transaction record'
/
comment on column cup_fin_message.trans_features_id is 'Identifier of Transaction Features. F-full presentment, P-partial presentment, R-refund, T-Tax refund, space-other transactions'
/
comment on column cup_fin_message.cardholder_bill_amount is 'Amount, cardholder billing'
/
comment on column cup_fin_message.cardholder_acc_currency is 'Currency code, cardholder billing'
/
comment on column cup_fin_message.bill_exch_rate is 'Conversion rate, cardholder billing'
/
comment on column cup_fin_message.settlement_exch_rate is 'Conversion rate, settlement'
/
comment on column cup_fin_message.service_fee_amount is 'Amount of services fee'
/
comment on column cup_fin_message.payment_service_type is 'Type of payment service requested'
/
alter table cup_fin_message drop column orig_trans_data
/
alter table cup_fin_message rename column agency_id to acquirer_iin
/
alter table cup_fin_message rename column issue_code to issuer_iin
/
alter table cup_fin_message rename column receive_inst_id to receiving_iin
/
alter table cup_fin_message rename column sending_inst_id to forwarding_iin
/
alter table cup_fin_message rename column acceptor_id_code to merchant_number
/
alter table cup_fin_message rename column term_id to terminal_number
/
alter table cup_fin_message rename column amt_tran to trans_amount
/
alter table cup_fin_message rename column code_of_trans_currency to auth_currency
/
alter table cup_fin_message rename column mrc_name to merchant_name
/
alter table cup_fin_message rename column country_code_of_term to terminal_country
/
alter table cup_fin_message rename column auth_resp_id to auth_resp_code
/
alter table cup_fin_message rename column cap_of_term to terminal_capab
/
alter table cup_fin_message rename column read_cap_of_term to terminal_entry_capab
/
alter table cup_fin_message rename column result_term_verif to terminal_verif_result
/
alter table cup_fin_message rename column serv_input_mode_code to pos_entry_mode
/
alter table cup_fin_message rename column term_cat to terminal_category
/
alter table cup_fin_message rename column tran_curr_code to trans_currency
/
alter table cup_fin_message rename column tran_init_channel to trans_init_channel
/
alter table cup_fin_message rename column trans_cat to trans_category
/
alter table cup_fin_message rename column trans_cnt to trans_counter
/
alter table cup_fin_message rename column trans_serial_cnt to trans_serial_counter
/
alter table cup_fin_message rename column bill_exch_rate to cardholder_exch_rate
/
alter table cup_fin_message add (sttl_amount number(12))
/
comment on column cup_fin_message.sttl_amount is 'Amount, settlement'
/
alter table cup_fin_message add (sttl_currency varchar2(3))
/
comment on column cup_fin_message.sttl_currency is 'Currency code, settlement'
/
alter table cup_fin_message add (message_type number(4))
/
comment on column cup_fin_message.message_type is 'Message type'
/
alter table cup_fin_message add (receivable_fee number(12))
/
comment on column cup_fin_message.receivable_fee is 'Receivable Fee'
/
alter table cup_fin_message add (payable_fee number(12))
/
comment on column cup_fin_message.payable_fee is 'Payable Fee'
/
alter table cup_fin_message add (dispute_id number(16))
/
comment on column cup_fin_message.dispute_id is 'Dispute ID'
/
alter table cup_fin_message add b2b_business_type varchar2(2)
/
comment on column cup_fin_message.b2b_business_type is 'B2B business type'
/
alter table cup_fin_message add b2b_payment_medium varchar2(1)
/
comment on column cup_fin_message.b2b_payment_medium is 'B2B payment medium'
/
alter table cup_fin_message add qrc_voucher_number varchar2(20)
/
comment on column cup_fin_message.qrc_voucher_number is 'QRC voucher number'
/
alter table cup_fin_message add payment_facilitator_id varchar2(8)
/
comment on column cup_fin_message.payment_facilitator_id is 'Payment facilitator identifier'
/
