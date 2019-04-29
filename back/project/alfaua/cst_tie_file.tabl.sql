create table cst_tie_file(
    id                  number(16)
  , is_incoming         number(1)
  , network_id          number(4)
  , file_name           varchar2(32)
  , file_version        varchar2(4)
  , ext_file_id         number(16)
  , inst_id             number(4)
  , records_count       number(8)
  , session_file_id     number(16)
)
/
comment on table cst_tie_file is 'Tieto clearing files'
/
comment on column cst_tie_file.id  is 'Primary key. Equal to ID in prc_session_file'
/
comment on column cst_tie_file.is_incoming  is '0 incoming file, 1 outgoing file'
/
comment on column cst_tie_file.network_id  is 'Network identifier'
/
comment on column cst_tie_file.file_name  is 'File name'
/
comment on column cst_tie_file.file_version  is 'File version'
/
comment on column cst_tie_file.ext_file_id  is 'External file ID'
/
comment on column cst_tie_file.inst_id  is 'Institution identifier'
/
comment on column cst_tie_file.records_count  is 'Number of records in file'
/
comment on column cst_tie_file.session_file_id  is 'Session ID'
/
