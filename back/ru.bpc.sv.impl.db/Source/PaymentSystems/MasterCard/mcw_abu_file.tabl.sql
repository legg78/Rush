create table mcw_abu_file (
    id                  number(16)
  , inst_id             number(4)
  , network_id          number(4)
  , file_type           varchar2(8)
  , proc_date           date
  , is_incoming         number(1)
  , business_ica        varchar2(11)
  , reason_code         varchar2(1)
  , original_file_date  date
  , total_msg_count     number(7)
  , total_add_count     number(7)
  , total_changed_count number(7)
  , total_error_count   number(7)
  , record_count        number(9)
)
/

comment on table mcw_abu_file is 'MasterCard ABU files'
/
comment on column mcw_abu_file.id is 'File identifier. Primary key. Equal to id from prc_session_file'
/
comment on column mcw_abu_file.inst_id is 'Institution identifier'
/
comment on column mcw_abu_file.network_id is 'Network identifier'
/
comment on column mcw_abu_file.file_type is 'ABU file type: R274, T275, R625, T626'
/
comment on column mcw_abu_file.proc_date is 'Processing date'
/
comment on column mcw_abu_file.is_incoming is 'Incoming indicator'
/
comment on column mcw_abu_file.business_ica is 'Issuer’s/Acquirer’s Customer ID/ICA Number'
/
comment on column mcw_abu_file.reason_code is 'Reason code'
/
comment on column mcw_abu_file.original_file_date is 'File date, from original Acquirer Merchant Registration Request file'
/
comment on column mcw_abu_file.total_msg_count is 'Total records processed'
/
comment on column mcw_abu_file.total_add_count is 'Total Records Successfully Added'
/
comment on column mcw_abu_file.total_changed_count is 'Total Records Successfully Changed'
/
comment on column mcw_abu_file.total_error_count is 'Total Error Records Returned'
/
comment on column mcw_abu_file.record_count is 'Total number of records in the file including header and trailer records'
/
