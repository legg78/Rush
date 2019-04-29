create table bgn_file (
    id                number(16)
  , file_type         varchar2(8)  
  , file_label        varchar2(10)
  , sender_code       varchar2(5)
  , receiver_code     varchar2(5)
  , file_number       number(3)
  , test_option       varchar2(1)
  , creation_date     date
  , gmt_offset        number(1)
  , bgn_sttl_type     varchar(4)
  , sttl_currency     varchar2(3)
  , interface_version varchar2(2)
  , journal_period    number(4)
  , debit_total       number(6)
  , credit_total      number(6)
  , debit_amount      number(22, 4)
  , credit_amount     number(22, 4)
  , debit_fee_amount  number(22, 4)
  , credit_fee_amount number(22, 4)
  , net_amount        number(22, 4)
  , sttl_date         date
  , package_total     number(6)
  , control_amount    number(13) 
)
/

comment on table bgn_file is 'BORICA clearing file'
/

comment on column bgn_file.id is 'Primary key. Equal to session_file.id'
/

comment on column bgn_file.file_type is 'Type of BORICA clearing file. FLTP dictionary'
/

comment on column bgn_file.file_label is 'File label from title of file'
/

comment on column bgn_file.sender_code is 'BORICA''s code of file sender. 59XXX'
/

comment on column bgn_file.receiver_code is 'BORICA''s code of file receiver. 59XXX'
/

comment on column bgn_file.file_number is 'Sequence number of file in day'
/

comment on column bgn_file.test_option is 'Test or real file'
/

comment on column bgn_file.creation_date is 'File creation date'
/

comment on column bgn_file.gmt_offset is 'GMT offset of file creation date'
/

comment on column bgn_file.bgn_sttl_type is 'BORICA''s code of settlement type'
/

comment on column bgn_file.sttl_currency is 'Settlement currency code'
/

comment on column bgn_file.interface_version is 'Interface version'
/

comment on column bgn_file.journal_period is 'Number of journal period of file'
/

comment on column bgn_file.debit_total is 'Total count of debit operations'
/

comment on column bgn_file.credit_total is 'Total count of credit operations'
/

comment on column bgn_file.debit_amount is 'Total debit amount'
/

comment on column bgn_file.credit_amount is 'Total credit amount'
/

comment on column bgn_file.debit_fee_amount is 'Total fee debit amount'
/

comment on column bgn_file.credit_fee_amount is 'Total fee credit amount'
/

comment on column bgn_file.net_amount is 'Net amount'
/

comment on column bgn_file.sttl_date is 'Settlement date'
/

comment on column bgn_file.package_total is 'Total number of packages'
/

comment on column bgn_file.control_amount is 'Control amount'
/

alter table bgn_file add is_incoming number(1)
/

comment on column bgn_file.is_incoming is 'Incoming file - 1, outgoing file - 0'
/

alter table bgn_file add error_total number(6)
/

comment on column bgn_file.error_total is 'Count of errors in SO file'
/

alter table bgn_file add (network_id number(4), inst_id number(4))
/

comment on column bgn_file.network_id is 'Network identifier'
/

comment on column bgn_file.inst_id is 'Instituition identifier'
/

alter table bgn_file add borica_sttl_date date
/
comment on column bgn_file.borica_sttl_date is 'Borica settlement date (QO)'
/
 