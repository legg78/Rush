create table cst_bnv_napas_fin_msg
(
    id                        number(16)
  , mti                       varchar2(4)
  , trans_code                varchar2(6)
  , service_code              varchar2(10)
  , channel_code              varchar2(2)
  , oper_amount               number(22, 4)
  , real_amount               number(22, 4)
  , oper_currency             varchar2(3)
  , sttl_amount               number(22, 4)
  , sttl_currency             varchar2(3)
  , sttl_exchange_rate        number(8, 8)
  , bill_amount               number(22, 4)
  , bill_real_amount          number(22, 4)
  , bill_currency             varchar2(3)
  , bill_exchange_rate        number(8, 8)
  , sys_trace_number          number(6)
  , trans_date                date
  , sttl_date                 date
  , mcc                       varchar2(4)
  , pos_entry_mode            number(3)
  , pos_condition_code        number(2)
  , terminal_number           varchar2(8)
  , acq_inst_bin              varchar2(8)
  , iss_inst_bin              varchar2(8)
  , merchant_number           varchar2(8)
  , bnb_inst_bin              varchar2(8)
  , src_account_number        varchar2(28)
  , dst_account_number        varchar2(28)
  , iss_fee_napas             number(22,4)
  , iss_fee_acq               number(22,4)
  , iss_fee_bnb               number(22,4)
  , acq_fee_napas             number(22,4)
  , acq_fee_iss               number(22,4)
  , acq_fee_bnb               number(22,4)
  , bnb_fee_napas             number(22,4)
  , bnb_fee_acq               number(22,4)
  , bnb_fee_iss               number(22,4)
  , rrn                       varchar2(12)
  , auth_code                 varchar2(6)
  , transaction_id            varchar2(16)
  , resp_code                 number(4)
  , is_dispute                number(1)
  , status                    varchar2(8)
  , file_id                   number(16)
  , record_number             number(8)
  , dispute_id                number(16)
  , match_oper_id             number(16)
  , is_reversal               number(1)
)
/

comment on table cst_bnv_napas_fin_msg is 'NAPAS messages.'
/
comment on column cst_bnv_napas_fin_msg.id is 'Primary key. Message identifier'
/
comment on column cst_bnv_napas_fin_msg.mti is 'Message type indicator'
/
comment on column cst_bnv_napas_fin_msg.trans_code is 'Transaction processing code'
/
comment on column cst_bnv_napas_fin_msg.service_code is 'Service Code – specified by NAPAS'
/
comment on column cst_bnv_napas_fin_msg.channel_code is 'Identification code of Transaction Channel field'
/
comment on column cst_bnv_napas_fin_msg.oper_amount is 'Transaction amount is converted in VND if the transaction performed oversea.'
/
comment on column cst_bnv_napas_fin_msg.real_amount is 'Real transaction amount is converted in VND.'
/
comment on column cst_bnv_napas_fin_msg.oper_currency is 'Currency code'
/
comment on column cst_bnv_napas_fin_msg.sttl_amount is 'Settlement Amount'
/
comment on column cst_bnv_napas_fin_msg.sttl_currency is 'Settlement currency'
/
comment on column cst_bnv_napas_fin_msg.sttl_exchange_rate is 'Settlement exchange rate'
/
comment on column cst_bnv_napas_fin_msg.bill_amount is 'Cardholder billing amount'
/
comment on column cst_bnv_napas_fin_msg.bill_real_amount is 'Real cardholder billing amount'
/
comment on column cst_bnv_napas_fin_msg.bill_currency is 'Cardholder billing currency'
/
comment on column cst_bnv_napas_fin_msg.bill_exchange_rate is 'Cardholder billing exchange rate'
/
comment on column cst_bnv_napas_fin_msg.sys_trace_number is 'System Trace Audit Number'
/
comment on column cst_bnv_napas_fin_msg.trans_date is 'Local transaction date and time'
/
comment on column cst_bnv_napas_fin_msg.sttl_date is 'Settlement date'
/
comment on column cst_bnv_napas_fin_msg.mcc is 'Merchant category code'
/
comment on column cst_bnv_napas_fin_msg.pos_entry_mode is 'Point of Service Entry Mode'
/
comment on column cst_bnv_napas_fin_msg.pos_condition_code is 'Point of Service Condition Code'
/
comment on column cst_bnv_napas_fin_msg.terminal_number is 'Card acceptor terminal identification'
/
comment on column cst_bnv_napas_fin_msg.acq_inst_bin is 'Acquirer identification code is registered in NAPAS'
/
comment on column cst_bnv_napas_fin_msg.iss_inst_bin is 'Issuer identification code is registered in NAPAS'
/
comment on column cst_bnv_napas_fin_msg.merchant_number is 'Card acceptor identification code'
/
comment on column cst_bnv_napas_fin_msg.bnb_inst_bin is 'Beneficiary identification code'
/
comment on column cst_bnv_napas_fin_msg.src_account_number is 'Source account number'
/
comment on column cst_bnv_napas_fin_msg.dst_account_number is 'Destination card/account number'
/
comment on column cst_bnv_napas_fin_msg.iss_fee_napas is 'Service fee of Issuer for NAPAS'
/
comment on column cst_bnv_napas_fin_msg.iss_fee_acq is 'Interchange fee of Issuer for Acquirer'
/
comment on column cst_bnv_napas_fin_msg.iss_fee_bnb is 'Interchange fee of Issuer for BNB'
/
comment on column cst_bnv_napas_fin_msg.acq_fee_napas is 'Service fee of Acquirer for NAPAS'
/
comment on column cst_bnv_napas_fin_msg.acq_fee_iss is 'Interchange fee of Acquirer for Issuer'
/
comment on column cst_bnv_napas_fin_msg.acq_fee_bnb is 'Interchange fee of Acquirer for BNB'
/
comment on column cst_bnv_napas_fin_msg.bnb_fee_napas is 'Service fee of BNB for NAPAS'
/
comment on column cst_bnv_napas_fin_msg.bnb_fee_acq is 'Interchange fee of BNB for Acquirer'
/
comment on column cst_bnv_napas_fin_msg.bnb_fee_iss is 'Interchange fee of BNB for Issuer'
/
comment on column cst_bnv_napas_fin_msg.rrn is 'Transaction reference number for reconciliation'
/
comment on column cst_bnv_napas_fin_msg.auth_code is 'Authorization number is responded from Issuer'
/
comment on column cst_bnv_napas_fin_msg.transaction_id is 'The transaction identification number is generated by NAPAS when the transaction is processed'
/
comment on column cst_bnv_napas_fin_msg.resp_code is 'Reconciliation Response Code is specified in the settlement process for MO'
/
comment on column cst_bnv_napas_fin_msg.is_dispute is '0 – from reconciliation file, 1 – from dispute file'
/
comment on column cst_bnv_napas_fin_msg.status is 'Transaction reconciliation status'
/
comment on column cst_bnv_napas_fin_msg.file_id is 'NAPAS file identifier'
/
comment on column cst_bnv_napas_fin_msg.record_number is 'NAPAS file record number'
/
comment on column cst_bnv_napas_fin_msg.dispute_id is 'Dispute identifier'
/
comment on column cst_bnv_napas_fin_msg.match_oper_id is 'Matched operation identifier'
/
comment on column cst_bnv_napas_fin_msg.is_reversal is '0 – not reversal, 1 – reversal'
/
alter table cst_bnv_napas_fin_msg modify (sttl_exchange_rate number(16, 8))
/
alter table cst_bnv_napas_fin_msg modify (bill_exchange_rate number(16, 8))
/
alter table cst_bnv_napas_fin_msg modify (merchant_number varchar2(15))
/
alter table cst_bnv_napas_fin_msg modify (terminal_number varchar2(16))
/
