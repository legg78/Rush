create table cst_250_1_oper_tran3(
    region_code           varchar2(20 char)
  , file_name             varchar2(200 byte)
  , session_file_id       number(16, 0)
  , file_date             date
  , customer_type         char(8 char)
  , card_feature          varchar2(8 char)
  , oper_id               number
  , oper_type             varchar2(8 byte)
  , is_mobile             number
  , is_internet           number
  , column_type           varchar2(20 char)
  , tran_code             varchar2(8 byte)
  , is_reversal           number
  , card_number           varchar2(96 byte)
  , card_id               number(12, 0)
  , contract_id           number(12, 0)
  , sttl_currency         varchar2(12 byte)
  , sttl_amount           number
  , conv_amount           number
  , credit_amount         number
  , oper_sign             number
  , debet_credit          varchar2(4 byte)
  , is_use                number
  , card_network_id       number
  , merchant_country      varchar2(12 byte)
  , terminal_number       varchar2(16 char)
  , pres_id               number(16, 0)
  , mcc                   varchar2(4 byte)
  , balance_type          varchar2(8 char)
  , is_card_contactless   number(1)
  , is_oper_contactless   number(1)
)
/
comment on table cst_250_1_oper_tran3 is 'Table based on cst_250_1_oper_tran2 excluding incorrect operations'
/
comment on column cst_250_1_oper_tran3.region_code is 'Region code'
/
comment on column cst_250_1_oper_tran3.file_name is 'File name'
/
comment on column cst_250_1_oper_tran3.session_file_id is 'Identifier of C-file'
/
comment on column cst_250_1_oper_tran3.file_date is 'File date'
/
comment on column cst_250_1_oper_tran3.customer_type is 'Customer type'
/
comment on column cst_250_1_oper_tran3.card_feature is 'Card feature'
/
comment on column cst_250_1_oper_tran3.oper_id is 'Operation ID'
/
comment on column cst_250_1_oper_tran3.oper_type is 'Operation type'
/
comment on column cst_250_1_oper_tran3.is_mobile is 'Is the operation done using a mobile phone'
/
comment on column cst_250_1_oper_tran3.is_internet is 'Is internet operation'
/
comment on column cst_250_1_oper_tran3.column_type is 'Column name for the report'
/
comment on column cst_250_1_oper_tran3.tran_code is 'Code transaction'
/
comment on column cst_250_1_oper_tran3.is_reversal is 'Is reversal'
/
comment on column cst_250_1_oper_tran3.card_number is 'Card number'
/
comment on column cst_250_1_oper_tran3.card_id is 'Card ID'
/
comment on column cst_250_1_oper_tran3.contract_id is 'Contract ID'
/
comment on column cst_250_1_oper_tran3.sttl_currency is 'Settlement currency'
/
comment on column cst_250_1_oper_tran3.sttl_amount is 'Settlement amount'
/
comment on column cst_250_1_oper_tran3.conv_amount is 'Converted amount'
/
comment on column cst_250_1_oper_tran3.credit_amount is 'Credit amount'
/
comment on column cst_250_1_oper_tran3.oper_sign is 'Operation sign'
/
comment on column cst_250_1_oper_tran3.debet_credit is 'Transaction direction'
/
comment on column cst_250_1_oper_tran3.is_use is 'Is use'
/
comment on column cst_250_1_oper_tran3.card_network_id is 'Card network'
/
comment on column cst_250_1_oper_tran3.merchant_country is 'Transaction country'
/
comment on column cst_250_1_oper_tran3.terminal_number is 'Terminal number'
/
comment on column cst_250_1_oper_tran3.pres_id is 'Presentment ID'
/
comment on column cst_250_1_oper_tran3.mcc is 'Merchant Category Code'
/
comment on column cst_250_1_oper_tran3.balance_type is 'Balance type'
/
comment on column cst_250_1_oper_tran3.is_card_contactless is 'Is card contactless'
/
comment on column cst_250_1_oper_tran3.is_oper_contactless is 'Is operation contactless'
/
