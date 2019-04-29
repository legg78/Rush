create table nps_fin_message
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

comment on table nps_fin_message is 'NAPAS financial messages.'
/
comment on column nps_fin_message.id is 'Primary key. Message identifier'
/
comment on column nps_fin_message.mti is 'Message type indicator'
/
comment on column nps_fin_message.trans_code is 'Transaction processing code'
/
comment on column nps_fin_message.service_code is 'Service Code – specified by NAPAS'
/
comment on column nps_fin_message.channel_code is 'Identification code of Transaction Channel field'
/
comment on column nps_fin_message.oper_amount is 'Transaction amount is converted in VND if the transaction performed oversea.'
/
comment on column nps_fin_message.real_amount is 'Real transaction amount is converted in VND.'
/
comment on column nps_fin_message.oper_currency is 'Currency code'
/
comment on column nps_fin_message.sttl_amount is 'Settlement Amount'
/
comment on column nps_fin_message.sttl_currency is 'Settlement currency'
/
comment on column nps_fin_message.sttl_exchange_rate is 'Settlement exchange rate'
/
comment on column nps_fin_message.bill_amount is 'Cardholder billing amount'
/
comment on column nps_fin_message.bill_real_amount is 'Real cardholder billing amount'
/
comment on column nps_fin_message.bill_currency is 'Cardholder billing currency'
/
comment on column nps_fin_message.bill_exchange_rate is 'Cardholder billing exchange rate'
/
comment on column nps_fin_message.sys_trace_number is 'System Trace Audit Number'
/
comment on column nps_fin_message.trans_date is 'Local transaction date and time'
/
comment on column nps_fin_message.sttl_date is 'Settlement date'
/
comment on column nps_fin_message.mcc is 'Merchant category code'
/
comment on column nps_fin_message.pos_entry_mode is 'Point of Service Entry Mode'
/
comment on column nps_fin_message.pos_condition_code is 'Point of Service Condition Code'
/
comment on column nps_fin_message.terminal_number is 'Card acceptor terminal identification'
/
comment on column nps_fin_message.acq_inst_bin is 'Acquirer identification code is registered in NAPAS'
/
comment on column nps_fin_message.iss_inst_bin is 'Issuer identification code is registered in NAPAS'
/
comment on column nps_fin_message.merchant_number is 'Card acceptor identification code'
/
comment on column nps_fin_message.bnb_inst_bin is 'Beneficiary identification code'
/
comment on column nps_fin_message.src_account_number is 'Source account number'
/
comment on column nps_fin_message.dst_account_number is 'Destination card/account number'
/
comment on column nps_fin_message.iss_fee_napas is 'Service fee of Issuer for NAPAS'
/
comment on column nps_fin_message.iss_fee_acq is 'Interchange fee of Issuer for Acquirer'
/
comment on column nps_fin_message.iss_fee_bnb is 'Interchange fee of Issuer for BNB'
/
comment on column nps_fin_message.acq_fee_napas is 'Service fee of Acquirer for NAPAS'
/
comment on column nps_fin_message.acq_fee_iss is 'Interchange fee of Acquirer for Issuer'
/
comment on column nps_fin_message.acq_fee_bnb is 'Interchange fee of Acquirer for BNB'
/
comment on column nps_fin_message.bnb_fee_napas is 'Service fee of BNB for NAPAS'
/
comment on column nps_fin_message.bnb_fee_acq is 'Interchange fee of BNB for Acquirer'
/
comment on column nps_fin_message.bnb_fee_iss is 'Interchange fee of BNB for Issuer'
/
comment on column nps_fin_message.rrn is 'Transaction reference number for reconciliation'
/
comment on column nps_fin_message.auth_code is 'Authorization number is responded from Issuer'
/
comment on column nps_fin_message.transaction_id is 'The transaction identification number is generated by NAPAS when the transaction is processed'
/
comment on column nps_fin_message.resp_code is 'Reconciliation Response Code is specified in the settlement process for MO'
/
comment on column nps_fin_message.is_dispute is '0 – from reconciliation file, 1 – from dispute file'
/
comment on column nps_fin_message.status is 'Transaction reconciliation status'
/
comment on column nps_fin_message.file_id is 'NAPAS file identifier'
/
comment on column nps_fin_message.record_number is 'NAPAS file record number'
/
comment on column nps_fin_message.dispute_id is 'Dispute identifier'
/
comment on column nps_fin_message.match_oper_id is 'Matched operation identifier'
/
comment on column nps_fin_message.is_reversal is '0 – not reversal, 1 – reversal'
/
alter table nps_fin_message modify (sttl_exchange_rate number(16, 8))
/
alter table nps_fin_message modify (bill_exchange_rate number(16, 8))
/
alter table nps_fin_message modify (merchant_number varchar2(15))
/
alter table nps_fin_message modify (terminal_number varchar2(16))
/
