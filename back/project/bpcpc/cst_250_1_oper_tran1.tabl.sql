create table cst_250_1_oper_tran1(
    file_date             date
  , file_name             varchar2(200)
  , session_file_id       number(16, 0)
  , oper_id               number
  , card_number           varchar2(96)
  , card_id               number(12, 0)
  , tran_code             varchar2(8)
  , oper_type             varchar2(8)
  , is_reversal           number
  , debet_credit          varchar2(4)
  , network_id            number
  , sttl_currency         varchar2(12)
  , sttl_amount           varchar2(60)
  , merchant_country      varchar2(12)
  , mcc                   varchar2(4)
  , terminal_number       varchar2(16)
  , is_internet           number
  , pres_id               number(16, 0)
  , is_use                number
  , record_number         number
  , contract_id           number(12)
  , card_type_id          number(4)
  , is_card_contactless   number(1)
  , is_oper_contactless   number(1)
)
/
comment on table cst_250_1_oper_tran1 is 'Combining the tables cst_250_1_file_tran and opr_operation and related tables'
/
comment on column cst_250_1_oper_tran1.file_date is 'File date'
/
comment on column cst_250_1_oper_tran1.session_file_id is 'Identifier of C-file'
/
comment on column cst_250_1_oper_tran1.oper_id is 'Operation ID'
/
comment on column cst_250_1_oper_tran1.card_number is 'Card number'
/
comment on column cst_250_1_oper_tran1.card_id is 'Card ID'
/
comment on column cst_250_1_oper_tran1.tran_code is 'Code transaction'
/
comment on column cst_250_1_oper_tran1.oper_type is 'Operation type'
/
comment on column cst_250_1_oper_tran1.is_reversal is 'Is reversal'
/
comment on column cst_250_1_oper_tran1.debet_credit is 'Transaction direction'
/
comment on column cst_250_1_oper_tran1.network_id is 'Card network'
/
comment on column cst_250_1_oper_tran1.sttl_currency is 'Settlement currency'
/
comment on column cst_250_1_oper_tran1.sttl_amount is 'Settlement amount'
/
comment on column cst_250_1_oper_tran1.merchant_country is 'Transaction country'
/
comment on column cst_250_1_oper_tran1.mcc is 'Merchant Category Code'
/
comment on column cst_250_1_oper_tran1.terminal_number is 'Terminal number'
/
comment on column cst_250_1_oper_tran1.is_internet is 'Is internet operation'
/
comment on column cst_250_1_oper_tran1.pres_id is 'Presentment ID'
/
comment on column cst_250_1_oper_tran1.is_use is 'Is use'
/
comment on column cst_250_1_oper_tran1.record_number is 'Record number'
/
comment on column cst_250_1_oper_tran1.contract_id is 'Contract ID'
/
comment on column cst_250_1_oper_tran1.card_type_id is 'Card type ID'
/
comment on column cst_250_1_oper_tran1.is_card_contactless is 'Is card contactless'
/
comment on column cst_250_1_oper_tran1.is_oper_contactless is 'Is operation contactless'
/
