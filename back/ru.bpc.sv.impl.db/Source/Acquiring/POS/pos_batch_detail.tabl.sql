create table pos_batch_detail (
    id                          number(16)
  , batch_block_id              number(16)
  , record_type                 varchar2(8)
  , record_number               number(12)
  , voucher_number              number(6)
  , card_number                 varchar2(24)
  , card_member_number          number(1)
  , card_expir_date             varchar2(4)
  , trans_amount                number(12, 4)
  , trans_currency              varchar2(3)
  , debit_credit                varchar2(2)
  , trans_date                  varchar2(8)
  , trans_time                  varchar2(8)
  , auth_code                   varchar2(6)
  , trans_type                  varchar2(3)
  , utrnno                      varchar2(12) 
  , is_reversal                 number(1)
  , auth_utrnno                 varchar2(12)
  , pos_data_code               varchar2(12)
  , retrieval_reference_number  varchar2(12)
  , trace_number                varchar2(6)
  , network_id                  number(3)
  , acq_inst_id                 varchar2(4)
  , trans_status                varchar2(8)
  , add_data                    varchar2(300)
  , emv_data                    varchar2(400)
  , service_id                  varchar2(8)
  , payment_details             varchar2(100)
  , service_provider_id         varchar2(10)
  , unique_number_payment       varchar2(25)
  , add_amounts                 varchar2(300)
  , svfe_trace_number           varchar2(12)
)
/
comment on table pos_batch_detail is 'POS batch file records list'
/
comment on column pos_batch_detail.id is 'Record identifier'
/
comment on column pos_batch_detail.batch_block_id is 'POS batch identifier'
/
comment on column pos_batch_detail.record_type is 'Record Type'
/
comment on column pos_batch_detail.record_number is 'Record Number '
/
comment on column pos_batch_detail.voucher_number is 'Voucher Number in a Batch'
/
comment on column pos_batch_detail.card_number is 'Card Number. PAN'
/
comment on column pos_batch_detail.card_member_number is 'Card Member Number'
/
comment on column pos_batch_detail.card_expir_date is 'Card Expiration date (YYMM)'
/
comment on column pos_batch_detail.trans_amount is 'Transaction Amount'
/
comment on column pos_batch_detail.trans_currency is 'Transaction Currency in ISO Numeric format'
/
comment on column pos_batch_detail.debit_credit is 'Debit/Credit'
/
comment on column pos_batch_detail.trans_date is 'Transaction Date (DDMMYYYY)'
/
comment on column pos_batch_detail.trans_time is 'Transaction Time (HHMMSS)'
/
comment on column pos_batch_detail.auth_code is 'Authorization code'
/
comment on column pos_batch_detail.trans_type is 'Transaction type'
/
comment on column pos_batch_detail.utrnno is 'FE Utrnno'
/
comment on column pos_batch_detail.is_reversal is 'Reversal Flag'
/
comment on column pos_batch_detail.auth_utrnno is 'Authorization FE Utrnno'
/
comment on column pos_batch_detail.pos_data_code is 'POS Data code'
/
comment on column pos_batch_detail.retrieval_reference_number is 'Retrieval Reference Number'
/
comment on column pos_batch_detail.trace_number is 'Trace number'
/
comment on column pos_batch_detail.network_id is 'Network identifier'
/
comment on column pos_batch_detail.acq_inst_id is 'Acquiring Institution Identification Code'
/
comment on column pos_batch_detail.trans_status is 'Transaction Status'
/
comment on column pos_batch_detail.add_data is 'Additional Data'
/
comment on column pos_batch_detail.emv_data is 'EMV Data'
/
comment on column pos_batch_detail.service_id is 'Service Identifier'
/
comment on column pos_batch_detail.payment_details is 'Payment details'
/
comment on column pos_batch_detail.service_provider_id is 'Service-provider identifier'
/
comment on column pos_batch_detail.unique_number_payment is 'Unique number of payment'
/
comment on column pos_batch_detail.add_amounts is 'Additional Amounts'
/
comment on column pos_batch_detail.svfe_trace_number is 'SVFE Trace number'
/
