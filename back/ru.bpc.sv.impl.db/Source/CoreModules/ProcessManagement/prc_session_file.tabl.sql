create table prc_session_file (
    id                number(16) not null
    , part_key        as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , session_id      number(16)
    , file_attr_id    number(8)
    , file_name       varchar2(200)
    , file_date       date
    , record_count    number(12)
    , crc_value       varchar2(200)
    , status          varchar2(8)
    , file_contents   clob
    , file_bcontents  blob
    , file_type       varchar2(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition prc_session_file_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table prc_session_file is 'Registration of files processed during run of session'
/

comment on column prc_session_file.id is 'Primary key.'
/
comment on column prc_session_file.session_id is 'Session identifier'
/
comment on column prc_session_file.file_attr_id is 'File attribute identifier'
/
comment on column prc_session_file.file_name is 'File name'
/
comment on column prc_session_file.file_date is 'File processing date.'
/
comment on column prc_session_file.record_count is 'Total number of records in file'
/
comment on column prc_session_file.crc_value is 'Crc value'
/
comment on column prc_session_file.status is 'Status of processing of file (accepted/rejected)'
/
comment on column prc_session_file.file_contents is 'File contents. A character large object.'
/
comment on column prc_session_file.file_bcontents is 'File contents. A binary large object.'
/
comment on column prc_session_file.file_type is 'File type'
/
alter table prc_session_file add file_xml_contents xmltype
/
comment on column prc_session_file.file_xml_contents is 'File contents. A xml object.'
/
alter table prc_session_file add thread_number number(4)
/
comment on column prc_session_file.thread_number is 'Thread number'
/

alter table prc_session_file add (object_id number(16))
/
comment on column prc_session_file.object_id is 'Object identifier.'
/
alter table prc_session_file add (entity_type varchar2(8))
/
comment on column prc_session_file.entity_type is 'Object entity type.'
/
