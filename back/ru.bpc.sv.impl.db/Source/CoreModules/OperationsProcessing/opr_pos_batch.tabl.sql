create table opr_pos_batch (
    oper_id                     number(16)
  , part_key                    as (to_date(substr(lpad(to_char(oper_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , voucher_number              number(6)
  , debit_credit                varchar2(2)
  , trans_type                  varchar2(3)
  , pos_data_code               varchar2(12)
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
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
  partition opr_pos_batch_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/
comment on table opr_pos_batch is 'Additional POS batch file infpormation'
/
comment on column opr_pos_batch.oper_id is 'Reference to operation'
/
comment on column opr_pos_batch.voucher_number is 'Voucher Number in a Batch'
/
comment on column opr_pos_batch.debit_credit is 'Debit/Credit'
/
comment on column opr_pos_batch.trans_type is 'Transaction type'
/
comment on column opr_pos_batch.pos_data_code is 'POS Data code'
/
comment on column opr_pos_batch.trans_status is 'Transaction Status'
/
comment on column opr_pos_batch.add_data is 'Additional Data'
/
comment on column opr_pos_batch.emv_data is 'EMV Data'
/
comment on column opr_pos_batch.service_id is 'Service Identifier'
/
comment on column opr_pos_batch.payment_details is 'Payment details'
/
comment on column opr_pos_batch.service_provider_id is 'Service-provider identifier'
/
comment on column opr_pos_batch.unique_number_payment is 'Unique number of payment'
/
comment on column opr_pos_batch.add_amounts is 'Additional Amounts'
/
comment on column opr_pos_batch.svfe_trace_number is 'SVFE Trace number'
/

