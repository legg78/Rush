create table cst_250_3_oper_tran1(
    oper_id                number
  , file_name              varchar2(200 byte)
  , session_file_id        number(16, 0)
  , file_date              date
  , region_code            varchar2(3 byte)
  , tran_code              varchar2(8 byte)
  , card_network_id        number
  , oper_type              varchar2(8 byte)
  , oper_sign              number
  , terminal_type          varchar2(8 byte)
  , is_mobile              number
  , actual_count           number
  , oper_group             number
  , card_us                number
  , term_us                number
  , country_iss_rf         number
  , country_opr_rf         number
  , foreign_currency       number
  , actual_amount          number
  , terminal_number        varchar2(16 byte)
  , contra_entry_channel   varchar2(1 char)
)
/
comment on table cst_250_3_oper_tran1 is 'Combining the tables cst_250_1_file_tran and opr_operation and related tables'
/
comment on column cst_250_3_oper_tran1.oper_id is 'Operation ID'
/
comment on column cst_250_3_oper_tran1.file_name is 'File name'
/
comment on column cst_250_3_oper_tran1.session_file_id is 'Identifier of M-file'
/
comment on column cst_250_3_oper_tran1.file_date is 'File date'
/
comment on column cst_250_3_oper_tran1.region_code is 'Region code'
/
comment on column cst_250_3_oper_tran1.tran_code is 'Code transaction'
/
comment on column cst_250_3_oper_tran1.card_network_id is 'Card network ID'
/
comment on column cst_250_3_oper_tran1.oper_type is 'Operation type'
/
comment on column cst_250_3_oper_tran1.oper_sign is 'Operation sign'
/
comment on column cst_250_3_oper_tran1.terminal_type is 'Terminal type'
/
comment on column cst_250_3_oper_tran1.is_mobile is 'Is the operation done using a mobile phone'
/
comment on column cst_250_3_oper_tran1.actual_count is 'Actual count'
/
comment on column cst_250_3_oper_tran1.oper_group is 'Column name for the report'
/
comment on column cst_250_3_oper_tran1.card_us is 'Is card us'
/
comment on column cst_250_3_oper_tran1.term_us is 'Is terminal us'
/
comment on column cst_250_3_oper_tran1.country_iss_rf is 'Is card issuer country Russia'
/
comment on column cst_250_3_oper_tran1.country_opr_rf is 'Is merchant country Russia'
/
comment on column cst_250_3_oper_tran1.foreign_currency is 'Foreign currency'
/
comment on column cst_250_3_oper_tran1.actual_amount is 'Actual amount'
/
comment on column cst_250_3_oper_tran1.terminal_number is 'Terminal number'
/
comment on column cst_250_3_oper_tran1.contra_entry_channel is 'Contra entry channel'
/
