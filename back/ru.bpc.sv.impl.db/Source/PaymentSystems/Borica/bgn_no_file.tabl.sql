create table bgn_no_file (
    id                  number(16)
  , bank_name           varchar2(200)
  , sttl_acc_number     varchar2(32)
  , sttl_date           date
  , sttl_ref            varchar2(200)
  , swift_msg_number    varchar2(200)
  , sttl_currency       varchar2(3)
  , ttt_debit_count     number(12)
  , ttt_debit_trans     number(22,4)  
  , ttt_debit_tax       number(22,4)
  , ttt_debit_total     number(22,4)
  , ttt_credit_count    number(12)
  , ttt_credit_trans    number(22,4)  
  , ttt_credit_tax      number(22,4)
  , ttt_credit_total    number(22,4)
  , total_amount        number(22,4)  
)
/

comment on table bgn_no_file is 'NO files'
/

comment on column bgn_no_file.id                is 'Primary key. Same as prc_session_file.id'
/

comment on column bgn_no_file.bank_name         is 'Bank name'
/

comment on column bgn_no_file.sttl_acc_number   is 'Settlement account number'
/

comment on column bgn_no_file.sttl_date         is 'Settlement date'
/

comment on column bgn_no_file.sttl_ref          is 'Settlement reference (TRN)'
/

comment on column bgn_no_file.swift_msg_number  is 'Message number (SWIFT)'
/

comment on column bgn_no_file.sttl_currency     is 'Settlement currency'
/

comment on column bgn_no_file.ttt_debit_count  is 'Count of debit operations'
/

comment on column bgn_no_file.ttt_debit_trans  is 'Amount of debit transactions'
/

comment on column bgn_no_file.ttt_debit_tax    is 'Interbank fees debit amount'
/

comment on column bgn_no_file.ttt_debit_total  is 'Total debit amount'
/

comment on column bgn_no_file.ttt_credit_count is 'Count of credit operations'
/

comment on column bgn_no_file.ttt_credit_trans is 'Amount of credit transactions'
/

comment on column bgn_no_file.ttt_credit_tax   is 'Interbank fees credit amount'
/

comment on column bgn_no_file.ttt_credit_total is 'Total credit amount'
/

comment on column bgn_no_file.total_amount     is 'Total amount. Positive - credit, negative - debit'
/

alter table bgn_no_file add is_incoming number(1)
/

comment on column bgn_no_file.is_incoming is 'Incoming file - 1, outgoing file - 0'
/
