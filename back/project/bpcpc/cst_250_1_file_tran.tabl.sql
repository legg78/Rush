create table cst_250_1_file_tran (
    file_name          varchar2(200 byte)
  , file_name_id       number(16, 0)
  , record_number      number
  , oper_id            number
  , tran_code          varchar2(8 byte)
  , is_reversal        number
  , card_number        varchar2(96 byte)
  , oper_currency      varchar2(12 byte)
  , oper_amount        varchar2(60 byte)
  , sttl_currency      varchar2(12 byte)
  , sttl_amount        varchar2(60 byte)
  , actual_currency    varchar2(12 byte)
  , actual_amount      varchar2(60 byte)
  , debet_credit       varchar2(4 byte)
  , merchant_country   varchar2(12 byte)
  , is_use             number
  , raw_data           varchar2(4000 byte)
)
/
comment on table cst_250_1_file_tran is 'Parsed C-files'
/
comment on column cst_250_1_file_tran.file_name is 'File name'
/
comment on column cst_250_1_file_tran.file_name_id is 'Identifier of C-file'
/
comment on column cst_250_1_file_tran.record_number is 'Record number'
/
comment on column cst_250_1_file_tran.oper_id is 'Operation ID'
/
comment on column cst_250_1_file_tran.tran_code is 'Code transaction'
/
comment on column cst_250_1_file_tran.is_reversal is 'Is reversal'
/
comment on column cst_250_1_file_tran.card_number is 'Card number'
/
comment on column cst_250_1_file_tran.oper_currency is 'Operation currency'
/
comment on column cst_250_1_file_tran.sttl_currency is 'Settlement currency'
/
comment on column cst_250_1_file_tran.sttl_amount is 'Settlement amount'
/
comment on column cst_250_1_file_tran.actual_currency is 'Account currency'
/
comment on column cst_250_1_file_tran.actual_amount is 'Account amount'
/
comment on column cst_250_1_file_tran.debet_credit is 'Transaction direction'
/
comment on column cst_250_1_file_tran.merchant_country is 'Transaction country'
/
comment on column cst_250_1_file_tran.is_use is 'Is use'
/
comment on column cst_250_1_file_tran.raw_data is 'Raw data'
/
