create table cst_tie_fin
(
  id                       NUMBER(16) not null,
  split_hash               NUMBER(4),
  status                   VARCHAR2(8),
  inst_id                  NUMBER(4),
  network_id               NUMBER(4),
  file_id                  NUMBER(16),
  is_incoming              NUMBER(1),
  is_reversal              NUMBER(1),
  is_invalid               NUMBER(1),
  is_rejected              NUMBER(1),
  reject_id                NUMBER(16),
  dispute_id               NUMBER(16),
  impact                   NUMBER(1),
  accnt_type_from          NUMBER(2),
  accnt_type_to            NUMBER(2),
  appr_code                NUMBER(6),
  acq_id                   VARCHAR2(12),
  arn                      VARCHAR2(23),
  batch_nr                 VARCHAR2(32),
  bill_amnt                NUMBER(22),
  bill_ccy                 NUMBER(3),
  business_application_id  VARCHAR2(1),
  card_capture_cap         VARCHAR2(1),
  card_data_input_cap      VARCHAR2(1),
  card_data_input_mode     VARCHAR2(1),
  card_data_output_cap     VARCHAR2(1),
  card_presence            VARCHAR2(1),
  card_seq_nr              NUMBER(3),
  cashback_amnt            NUMBER(22),
  cat_level                VARCHAR2(1),
  chb_ref_data             NUMBER(22),
  crdh_auth_cap            VARCHAR2(1),
  crdh_auth_entity         VARCHAR2(1),
  crdh_auth_method         VARCHAR2(1),
  crdh_presence            VARCHAR2(1),
  cvv2_result              VARCHAR2(1),
  card_exp_date            date,
  doc_ind                  NUMBER(1),
  ecomm_sec_level          VARCHAR2(1),
  fwd_inst_id              NUMBER(11),
  mcc                      NUMBER(4),
  merchant_id              VARCHAR2(15),
  merchant_name            VARCHAR2(32),
  merchant_addr            VARCHAR2(64),
  merchant_country         VARCHAR2(3),
  merchant_city            VARCHAR2(21),
  merchant_postal_code     VARCHAR2(10),
  msg_funct_code           NUMBER(3),
  msg_reason_code          NUMBER(4),
  mti                      NUMBER(4),
  oper_env                 VARCHAR2(1),
  orig_reason_code         VARCHAR2(4),
  pin_capture_cap          VARCHAR2(1),
  proc_date                DATE,
  receiver_an              VARCHAR2(34),
  receiver_an_type_id      VARCHAR2(1),
  receiver_inst_code       VARCHAR2(32),
  resp_code                NUMBER(3),
  rrn                      VARCHAR2(32),
  sender_rn                VARCHAR2(16),
  sender_an                VARCHAR2(34),
  sender_an_type_id        VARCHAR2(1),
  sender_name              VARCHAR2(30),
  sender_addr              VARCHAR2(35),
  sender_city              VARCHAR2(25),
  sender_inst_code         VARCHAR2(32),
  sender_state             VARCHAR2(2),
  sender_country           VARCHAR2(3),
  settl_amnt               NUMBER(22),
  settl_ccy                NUMBER(3),
  settl_date               DATE,
  stan                     NUMBER(6),
  card_svc_code            NUMBER(3),
  term_data_output_cap     VARCHAR2(1),
  term_id                  VARCHAR2(8),
  tran_amnt                NUMBER(22),
  tran_ccy                 NUMBER(3),
  tran_date_time           DATE,
  tran_originator          VARCHAR2(11),
  tran_destination         VARCHAR2(11),
  tran_type                VARCHAR2(2),
  tid                      VARCHAR2(32),
  tid_originator           VARCHAR2(11),
  multiple_clearing_rec    NUMBER(4),
  validation_code          VARCHAR2(4),
  wallet_id                NUMBER(3),
  ptti                     VARCHAR2(3),
  payment_facilitator_id   NUMBER(11),
  independent_sales_org_id NUMBER(11),
  additional_merchant_info VARCHAR2(99),
  emv5f2a                  VARCHAR2(3),
  emv5f34                  VARCHAR2(2),
  emv71                    VARCHAR2(99),
  emv72                    VARCHAR2(99),
  emv82                    VARCHAR2(4),
  emv84                    VARCHAR2(32),
  emv91                    VARCHAR2(32),
  emv95                    VARCHAR2(10),
  emv9a                    VARCHAR2(6),
  emv9c                    VARCHAR2(2),
  emv9f02                  VARCHAR2(12),
  emv9f03                  VARCHAR2(12),
  emv9f09                  VARCHAR2(4),
  emv9f10                  VARCHAR2(64),
  emv9f1a                  VARCHAR2(3),
  emv9f1e                  VARCHAR2(8),
  emv9f26                  VARCHAR2(16),
  emv9f27                  VARCHAR2(2),
  emv9f33                  VARCHAR2(6),
  emv9f34                  VARCHAR2(6),
  emv9f35                  VARCHAR2(2),
  emv9f36                  VARCHAR2(4),
  emv9f37                  VARCHAR2(8),
  emv9f41                  VARCHAR2(8),
  emv9f53                  VARCHAR2(99),
  emv9f6e                  VARCHAR2(4),
  msg_nr                   VARCHAR2(32),
  payment_narrative        VARCHAR2(256)
)
/
comment on table cst_tie_fin is 'Local clearing financial messages in Tieto format'
/
comment on column cst_tie_fin.id is 'Identifier'
/
comment on column cst_tie_fin.split_hash is 'Hash value to split further processing'
/
comment on column cst_tie_fin.status is 'Clearing message status'
/
comment on column cst_tie_fin.inst_id is 'Institution identifier'
/
comment on column cst_tie_fin.network_id is 'Network identifier'
/
comment on column cst_tie_fin.file_id is 'Logical file identifier'
/
comment on column cst_tie_fin.is_incoming is 'Incoming indicator'
/
comment on column cst_tie_fin.is_reversal is 'Reversal indicator'
/
comment on column cst_tie_fin.is_invalid is 'Invalid indicator'
/
comment on column cst_tie_fin.is_rejected is 'Rejected indicator'
/
comment on column cst_tie_fin.reject_id is 'Reject message identifier'
/
comment on column cst_tie_fin.dispute_id is 'Dispute identifier'
/
comment on column cst_tie_fin.impact is 'Message impact'
/
comment on column cst_tie_fin.accnt_type_from is 'Cardholder “from” account type code'
/
comment on column cst_tie_fin.accnt_type_to is 'Cardholder “to” account type code'
/
comment on column cst_tie_fin.appr_code is 'Approval code'
/
comment on column cst_tie_fin.acq_id is 'Acquiring institution identification code'
/
comment on column cst_tie_fin.arn is 'Acquirer reference number'
/
comment on column cst_tie_fin.batch_nr is 'Batch identifier'
/
comment on column cst_tie_fin.bill_amnt is 'Cardholder billing amount'
/
comment on column cst_tie_fin.bill_ccy is 'Cardholder billing currency'
/
comment on column cst_tie_fin.business_application_id is 'Message business application'
/
comment on column cst_tie_fin.card_capture_cap is 'Card capture capability'
/
comment on column cst_tie_fin.card_data_input_cap is 'Card data input capability'
/
comment on column cst_tie_fin.card_data_input_mode is 'Card data input mode'
/
comment on column cst_tie_fin.card_data_output_cap is 'Card Data Output Capability'
/
comment on column cst_tie_fin.card_presence is 'Card presence indicator'
/
comment on column cst_tie_fin.card_seq_nr is 'Card sequence number'
/
comment on column cst_tie_fin.cashback_amnt is 'Cashback amount'
/
comment on column cst_tie_fin.cat_level is 'Cardholder-activated-terminal level'
/
comment on column cst_tie_fin.chb_ref_data is 'Chargeback reference data'
/
comment on column cst_tie_fin.crdh_auth_cap is 'Cardholder authentication capability'
/
comment on column cst_tie_fin.crdh_auth_entity is 'Cardholder authentication entity'
/
comment on column cst_tie_fin.crdh_auth_method is 'Cardholder authentication method'
/
comment on column cst_tie_fin.crdh_presence is 'Cardholder presence indicator'
/
comment on column cst_tie_fin.cvv2_result is 'CVC2 result code'
/
comment on column cst_tie_fin.card_exp_date is 'Card expiry date'
/
comment on column cst_tie_fin.doc_ind is 'Documentation indicator'
/
comment on column cst_tie_fin.ecomm_sec_level is 'E-commerce security level'
/
comment on column cst_tie_fin.fwd_inst_id is 'Forwarding institution identification code, according to the solution'
/
comment on column cst_tie_fin.mcc is 'Merchant category code'
/
comment on column cst_tie_fin.merchant_id is 'Merchant Identification'
/
comment on column cst_tie_fin.merchant_name is 'Merchant Name'
/
comment on column cst_tie_fin.merchant_addr is 'Merchant address'
/
comment on column cst_tie_fin.merchant_country is 'Merchant country'
/
comment on column cst_tie_fin.merchant_city is 'Merchant city'
/
comment on column cst_tie_fin.merchant_postal_code is 'Merchant Postal Code'
/
comment on column cst_tie_fin.msg_funct_code is 'Message Function Code'
/
comment on column cst_tie_fin.msg_reason_code is 'Message Reason Code'
/
comment on column cst_tie_fin.mti is 'Message type identifier'
/
comment on column cst_tie_fin.oper_env is 'Operational environment'
/
comment on column cst_tie_fin.orig_reason_code is 'Initial Message Reason Code (MasterCard)'
/
comment on column cst_tie_fin.pin_capture_cap is 'PIN Capture Capability'
/
comment on column cst_tie_fin.proc_date is 'Processing Date (YYYYMMDD)'
/
comment on column cst_tie_fin.receiver_an is 'Receiver Account number'
/
comment on column cst_tie_fin.receiver_an_type_id is 'Receiver Account type identifier'
/
comment on column cst_tie_fin.receiver_inst_code is 'Receiver Institution code'
/
comment on column cst_tie_fin.resp_code is 'Response code'
/
comment on column cst_tie_fin.rrn is 'Retrieval reference number'
/
comment on column cst_tie_fin.sender_rn is 'Sender reference number'
/
comment on column cst_tie_fin.sender_an is 'Sender Account number'
/
comment on column cst_tie_fin.sender_an_type_id is 'Sender Account type identifier'
/
comment on column cst_tie_fin.sender_name is 'Sender Name'
/
comment on column cst_tie_fin.sender_addr is 'Sender Address'
/
comment on column cst_tie_fin.sender_city is 'Sender City'
/
comment on column cst_tie_fin.sender_inst_code is 'Sender Institution code'
/
comment on column cst_tie_fin.sender_state is 'Sender State'
/
comment on column cst_tie_fin.sender_country is 'Sender Country'
/
comment on column cst_tie_fin.settl_amnt is 'Settlement amount. In partial cases, differ from the original presentment amount'
/
comment on column cst_tie_fin.settl_ccy is 'Settlement currency'
/
comment on column cst_tie_fin.settl_date is 'Settlement date'
/
comment on column cst_tie_fin.stan is 'System trace audit number'
/
comment on column cst_tie_fin.card_svc_code is 'Service code'
/
comment on column cst_tie_fin.term_data_output_cap is 'Terminal data output capability'
/
comment on column cst_tie_fin.term_id is 'Terminal identification'
/
comment on column cst_tie_fin.tran_amnt is 'Transaction amount. In partial cases, differ from the original presentment amount'
/
comment on column cst_tie_fin.tran_ccy is 'Transaction currency'
/
comment on column cst_tie_fin.tran_date_time is 'Transaction date and time'
/
comment on column cst_tie_fin.tran_originator is 'Originator institution ID'
/
comment on column cst_tie_fin.tran_destination is 'Destination institution ID. In VISA transactions contains the same value as DstBin.'
/
comment on column cst_tie_fin.tran_type is 'Transaction type'
/
comment on column cst_tie_fin.tid is 'Transaction Identification'
/
comment on column cst_tie_fin.tid_originator is 'Network or Institution which assigned Tid'
/
comment on column cst_tie_fin.multiple_clearing_rec is 'Number and total count of multiple clearing records in format XXYY, where XX – sequence number, YY – total count of multiple clearing records'
/
comment on column cst_tie_fin.validation_code is 'Validation code'
/
comment on column cst_tie_fin.wallet_id is 'Wallet identifier (for MasterCard transaction Mandatory): 101 (PPOL Remote) –wallet data was created by the cardholder manually entering the data at a consumer controlled device (for example, computer, tablet, or phone); 102 (PPOL Remote NFC Payment) – wallet data was initially created by the cardholder tapping their Contactless MasterCard or Maestro card or device at a contactless card reader.'
/
comment on column cst_tie_fin.ptti is 'Payment Transaction Type Indicator'
/
comment on column cst_tie_fin.payment_facilitator_id is 'Payment Facilitator ID'
/
comment on column cst_tie_fin.independent_sales_org_id is 'Independent Sales Organization ID'
/
comment on column cst_tie_fin.additional_merchant_info is 'Additional Merchant Information'
/
comment on column cst_tie_fin.emv5f2a is 'EMV Tag 5F2A: Transaction Currency Code'
/
comment on column cst_tie_fin.emv5f34 is 'EMV Tag 5F34: PAN Sequence number'
/
comment on column cst_tie_fin.emv71 is 'EMV Tag 71: Issuer Script Template 1 (HEX)'
/
comment on column cst_tie_fin.emv72 is 'EMV Tag 72: Issuer Script Template 2 (HEX)'
/
comment on column cst_tie_fin.emv82 is 'EMV Tag 82: Application Interchange Profile (HEX)'
/
comment on column cst_tie_fin.emv84 is 'EMV Tag 84: Dedicated File Name (HEX)'
/
comment on column cst_tie_fin.emv91 is 'EMV Tag 91: Issuer Authentication Data (HEX)'
/
comment on column cst_tie_fin.emv95 is 'EMV Tag 95: Terminal Verification Result (TVR) (HEX)'
/
comment on column cst_tie_fin.emv9a is 'EMV Tag 9A: Transaction Date (YYMMDD)'
/
comment on column cst_tie_fin.emv9c is 'EMV Tag 9C: Transaction Type'
/
comment on column cst_tie_fin.emv9f02 is 'EMV Tag 9F02: Amount Authorized'
/
comment on column cst_tie_fin.emv9f03 is 'EMV Tag 9F03: Amount Other'
/
comment on column cst_tie_fin.emv9f09 is 'EMV Tag 9F09: Application Version Number (HEX)'
/
comment on column cst_tie_fin.emv9f10 is 'EMV Tag 9F10: Issuer Application Data (IAD) (HEX)'
/
comment on column cst_tie_fin.emv9f1a is 'EMV Tag 9F1A: Terminal Country Code'
/
comment on column cst_tie_fin.emv9f1e is 'EMV Tag 9F1E: Terminal Serial Number (HEX)'
/
comment on column cst_tie_fin.emv9f26 is 'EMV Tag 9F26: Application Cryptogram (AC) (HEX)'
/
comment on column cst_tie_fin.emv9f27 is 'EMV Tag 9F27: Cryptogram Information Data (HEX)'
/
comment on column cst_tie_fin.emv9f33 is 'EMV Tag 9F33: Terminal Capabilities (HEX)'
/
comment on column cst_tie_fin.emv9f34 is 'EMV Tag 9F34: CVM Results (HEX)'
/
comment on column cst_tie_fin.emv9f35 is 'EMV Tag 9F35: Terminal Type'
/
comment on column cst_tie_fin.emv9f36 is 'EMV Tag 9F36: Application Transaction Counter (HEX)'
/
comment on column cst_tie_fin.emv9f37 is 'EMV Tag 9F37: Unpredictable Number (HEX)'
/
comment on column cst_tie_fin.emv9f41 is 'EMV Tag 9F41: Transaction Sequence Counter'
/
comment on column cst_tie_fin.emv9f53 is 'EMV Tag 9F53: Transaction Category Code (HEX)'
/
comment on column cst_tie_fin.emv9f6e is 'EMV Tag 9F6E: Form Factor Indicator (FFI) for VISA payWave and MasterCard (PDS 0198) - Device Type'
/
comment on column cst_tie_fin.msg_nr is 'File scope unique message ID'
/
comment on column cst_tie_fin.payment_narrative is 'Notes of the payment'
/
