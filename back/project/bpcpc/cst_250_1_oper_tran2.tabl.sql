create table cst_250_1_oper_tran2(
    region_code           varchar2(20)
  , file_name             varchar2(200 byte)
  , session_file_id       number(16) not null
  , file_date             date
  , customer_type         char(8)
  , card_feature          varchar2(8)
  , oper_id               number
  , oper_type             varchar2(8 byte)
  , is_mobile             number
  , is_internet           number
  , column_type           varchar2(20)
  , tran_code             varchar2(20 byte)
  , is_reversal           number
  , card_number           varchar2(96 byte)
  , card_id               number(12) not null
  , contract_id           number(12)
  , sttl_currency         varchar2(12 byte)
  , sttl_amount           number
  , conv_amount           number
  , credit_amount         number
  , oper_sign             number
  , debet_credit          varchar2(4 byte)
  , is_use                number
  , card_network_id       number
  , merchant_country      varchar2(12 byte)
  , terminal_number       varchar2(16)
  , pres_id               number(16)
  , mcc                   varchar2(4 byte)
  , balance_type          varchar2(8)
  , is_card_contactless   number(1)
  , is_oper_contactless   number(1)
)
/
comment on table cst_250_1_oper_tran2 is 'Logical manipulation with data of cst_250_1_oper_tran1'
/
comment on column cst_250_1_oper_tran2.region_code is 'Region code'
/
comment on column cst_250_1_oper_tran2.file_name is 'File name'
/
comment on column cst_250_1_oper_tran2.session_file_id is 'Identifier of C-file'
/
comment on column cst_250_1_oper_tran2.file_date is 'File date'
/
comment on column cst_250_1_oper_tran2.customer_type is 'Customer type'
/
comment on column cst_250_1_oper_tran2.card_feature is 'Card feature'
/
comment on column cst_250_1_oper_tran2.oper_id is 'Operation ID'
/
comment on column cst_250_1_oper_tran2.oper_type is 'Operation type'
/
comment on column cst_250_1_oper_tran2.is_mobile is 'Is the operation done using a mobile phone'
/
comment on column cst_250_1_oper_tran2.is_internet is 'Is internet operation'
/
comment on column cst_250_1_oper_tran2.column_type is 'Column name for the report'
/
comment on column cst_250_1_oper_tran2.tran_code is 'Code transaction'
/
comment on column cst_250_1_oper_tran2.is_reversal is 'Is reversal'
/
comment on column cst_250_1_oper_tran2.card_number is 'Card number'
/
comment on column cst_250_1_oper_tran2.card_id is 'Card ID'
/
comment on column cst_250_1_oper_tran2.contract_id is 'Contract ID'
/
comment on column cst_250_1_oper_tran2.sttl_currency is 'Settlement currency'
/
comment on column cst_250_1_oper_tran2.sttl_amount is 'Settlement amount'
/
comment on column cst_250_1_oper_tran2.conv_amount is 'Converted amount'
/
comment on column cst_250_1_oper_tran2.credit_amount is 'Credit amount'
/
comment on column cst_250_1_oper_tran2.oper_sign is 'Operation sign'
/
comment on column cst_250_1_oper_tran2.debet_credit is 'Transaction direction'
/
comment on column cst_250_1_oper_tran2.is_use is 'Is use'
/
comment on column cst_250_1_oper_tran2.card_network_id is 'Card network'
/
comment on column cst_250_1_oper_tran2.merchant_country is 'Transaction country'
/
comment on column cst_250_1_oper_tran2.terminal_number is 'Terminal number'
/
comment on column cst_250_1_oper_tran2.pres_id is 'Presentment ID'
/
comment on column cst_250_1_oper_tran2.mcc is 'Merchant Category Code'
/
comment on column cst_250_1_oper_tran2.balance_type is 'Balance type'
/
comment on column cst_250_1_oper_tran2.is_card_contactless is 'Is card contactless'
/
comment on column cst_250_1_oper_tran2.is_oper_contactless is 'Is operation contactless'
/
