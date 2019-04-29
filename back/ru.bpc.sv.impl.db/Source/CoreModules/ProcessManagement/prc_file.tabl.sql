create table prc_file (
    id                  number(4)
  , process_id          number(8)
  , file_purpose        varchar2(8)
  , saver_class         varchar2(200)
  , file_nature         varchar2(8)
  , xsd_source          clob
  , file_type           varchar2(8)
)
/
comment on table prc_file is 'Files which are used by process'
/
comment on column prc_file.id is 'Identifier of file'
/
comment on column prc_file.process_id is 'Identifier of process'
/
comment on column prc_file.file_purpose is 'File data direction (incoming/outgoung).'
/
comment on column prc_file.saver_class is 'Java handler for saving files.'
/
comment on column prc_file.file_nature is 'File nature (FLNT dictionary).'
/
comment on column prc_file.xsd_source is 'XML schema definition source'
/
comment on column prc_file.file_type is 'File type.'
/
alter table prc_file add saver_id number(4)
/
comment on column prc_file.saver_id is 'Identifier of file saver.'
/