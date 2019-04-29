create table pos_batch_file (
    id                      number(8)
  , session_id              number(16)
  , session_file_id         number(16)
  , status                  varchar2(8)
  , proc_date               date
  , header_record_type      varchar2(8)
  , header_record_number    number(12)
  , file_type               varchar2(8)
  , creation_date           varchar2(8)
  , creation_time           varchar2(8)
  , inst_id                 varchar2(12)
  , batch_version           varchar2(3)
  , trailer_record_type      varchar2(8)
  , trailer_record_number    number(12)
  , total_batch_number      number(12)
)
/
comment on table pos_batch_file is 'POS batch file list'
/
comment on column pos_batch_file.id is 'Record identifier'
/
comment on column pos_batch_file.session_id is 'Identifier of session which record was created'
/
comment on column pos_batch_file.session_file_id is 'Session file identifier'
/
comment on column pos_batch_file.status is 'Status'
/
comment on column pos_batch_file.proc_date is 'Date of loading and processing'
/
comment on column pos_batch_file.header_record_type is 'Header Record Type'
/
comment on column pos_batch_file.header_record_number is ' Header Record Number'
/
comment on column pos_batch_file.file_type is 'File Type'
/
comment on column pos_batch_file.creation_date is 'Creation Date'
/
comment on column pos_batch_file.creation_time is 'Creation Time'
/
comment on column pos_batch_file.inst_id is 'Institution identifier'
/
comment on column pos_batch_file.batch_version is 'Batch version'
/
comment on column pos_batch_file.trailer_record_type is 'Trailer Record Type'
/
comment on column pos_batch_file.trailer_record_number is 'Trailer Record Number'
/
comment on column pos_batch_file.total_batch_number is 'Total Batch Number'
/
