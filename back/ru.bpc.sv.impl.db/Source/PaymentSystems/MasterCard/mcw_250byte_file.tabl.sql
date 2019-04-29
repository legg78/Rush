create table mcw_250byte_file
(
    id                  number(16)
  , header_mti          varchar2(4)
  , sttl_date           date
  , processor_id        varchar2(10)
  , record_size         number(3)
  , file_type           varchar2(1)
  , version             varchar2(10)
  , session_file_id     number(16)
  , inst_id             number(4)
  , network_id          number(4)
  , total_count         number(11)
)
/
comment on table mcw_250byte_file is 'MasterCard single message files.'
/
comment on column mcw_250byte_file.id is 'Identifier. Primary key.'
/
comment on column mcw_250byte_file.header_mti is 'The Message Type Identifier of file header.'
/
comment on column mcw_250byte_file.sttl_date is 'Settlement date. Format: MMDDYY.'
/
comment on column mcw_250byte_file.processor_id is 'MasterCard-assigned Processor ID.'
/
comment on column mcw_250byte_file.record_size is 'Size 250.'
/
comment on column mcw_250byte_file.file_type is 'Valid values are: M Member Testing File, P Production File.'
/
comment on column mcw_250byte_file.version is 'Current version number of the Batch Data File.'
/
comment on column mcw_250byte_file.session_file_id is 'Session file identifier.'
/
comment on column mcw_250byte_file.inst_id is 'Institution identifier.'
/
comment on column mcw_250byte_file.network_id is 'Payment network identifier.'
/
comment on column mcw_250byte_file.total_count is 'Total number of all records including file header record, addendums, financial control records and file trailer.'
/
