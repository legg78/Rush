create table cst_260_file_tran (
    file_name              varchar2(200 byte)
  , session_file_id        number(16, 0)
  , file_date              date
  , oper_id                number
  , card_type              varchar2(8 byte)
  , tran_code              varchar2(8 byte)
  , is_reversal            number
  , card_number            varchar2(96 byte)
  , oper_currency          varchar2(12 byte)
  , oper_amount            varchar2(60 byte)
  , sttl_currency          varchar2(12 byte)
  , sttl_amount            varchar2(60 byte)
  , actual_currency        varchar2(12 byte)
  , actual_amount          varchar2(60 byte)
  , contra_entry_channel   varchar2(4 byte)
  , oper_sign              number
  , terminal_number        varchar2(96 byte)
  , raw_data               varchar2(4000 byte)
)
/
comment on table cst_260_file_tran is 'Parsed M-files'
/
comment on column cst_260_file_tran.session_file_id is 'Identifier of M-file'
/
comment on column cst_260_file_tran.file_name is 'File name'
/
comment on column cst_260_file_tran.file_date is 'File date'
/
comment on column cst_260_file_tran.oper_id is 'Operation ID'
/
comment on column cst_260_file_tran.card_type is 'Card type'
/
comment on column cst_260_file_tran.tran_code is 'Code transaction'
/
comment on column cst_260_file_tran.is_reversal is 'Is reversal'
/
comment on column cst_260_file_tran.card_number is 'Card number'
/
comment on column cst_260_file_tran.oper_currency is 'Operation currency'
/
comment on column cst_260_file_tran.oper_amount is 'Operation amount'
/
comment on column cst_260_file_tran.sttl_currency is 'Settlement currency'
/
comment on column cst_260_file_tran.sttl_amount is 'Settlement amount'
/
comment on column cst_260_file_tran.actual_currency is 'Account currency'
/
comment on column cst_260_file_tran.actual_amount is 'Account amount'
/
comment on column cst_260_file_tran.contra_entry_channel is 'Contra entry channel'
/
comment on column cst_260_file_tran.oper_sign is 'Operation sign'
/
comment on column cst_260_file_tran.terminal_number is 'Terminal number'
/
comment on column cst_260_file_tran.raw_data is 'Raw data'
/
