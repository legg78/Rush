create table cst_250_3_oper_tran2 (
    oper_id                number
  , region_code            varchar2(3 byte)
  , subsection             number
  , network_id             number
  , oper_group             number
  , terminal_type          varchar2(8 byte)
  , foreign_currency       number
  , oper_type              varchar2(8 byte)
  , actual_count           number
  , actual_amount          number
  , is_mobile              number
  , terminal_number        varchar2(16 byte)
  , file_name              varchar2(200 char)
  , session_file_id        number(16, 0)
  , file_date              date
  , tran_code              varchar2(8 char)
  , card_us                number
  , country_iss_rf         number
  , country_opr_rf         number
  , contra_entry_channel   varchar2(1 char)
  , agent_id               number(8, 0)
)
/
comment on table cst_250_3_oper_tran2 is 'Logical manipulation with data of cst_250_3_oper_tran1'
/
comment on column cst_250_3_oper_tran2.oper_id is 'Operation ID'
/
comment on column cst_250_3_oper_tran2.region_code is 'Region code'
/
comment on column cst_250_3_oper_tran2.subsection is 'Subsection'
/
comment on column cst_250_3_oper_tran2.network_id is 'Card network ID'
/
comment on column cst_250_3_oper_tran2.oper_group is 'Column name for the report'
/
comment on column cst_250_3_oper_tran2.terminal_type is 'Terminal type'
/
comment on column cst_250_3_oper_tran2.foreign_currency is 'Foreign currency'
/
comment on column cst_250_3_oper_tran2.oper_type is 'Operation type'
/
comment on column cst_250_3_oper_tran2.actual_count is 'Actual count'
/
comment on column cst_250_3_oper_tran2.actual_amount is 'Actual amount'
/
comment on column cst_250_3_oper_tran2.is_mobile is 'Is the operation done using a mobile phone'
/
comment on column cst_250_3_oper_tran2.terminal_number is 'Terminal number'
/
comment on column cst_250_3_oper_tran2.file_name is 'File name'
/
comment on column cst_250_3_oper_tran2.session_file_id is 'Identifier of M-file'
/
comment on column cst_250_3_oper_tran2.file_date is 'File date'
/
comment on column cst_250_3_oper_tran2.tran_code is 'Code transaction'
/
comment on column cst_250_3_oper_tran2.card_us is 'Is card us'
/
comment on column cst_250_3_oper_tran2.country_iss_rf is 'Is card issuer country Russia'
/
comment on column cst_250_3_oper_tran2.country_opr_rf is 'Is merchant country Russia'
/
comment on column cst_250_3_oper_tran2.contra_entry_channel is 'Contra entry channel'
/
comment on column cst_250_3_oper_tran2.agent_id is 'Agent ID'
/
