create table prc_file_attribute (
    id                 number(8)
  , file_id            number(4)
  , container_id       number(8)
  , characterset       varchar2(30)
  , file_name_mask     varchar2(200)
  , name_format_id     number(4)
  , upload_empty_file  number(1)
  , location           varchar2(200)
  , xslt_source        clob
  , converter_class    varchar2(200)
  , is_tar             number(1)
  , is_zip             number(1)
  , inst_id            number(4)
  , report_id          number(8)
  , report_template_id number(8)
)
/

comment on table prc_file_attribute is 'Attributes of files'
/

comment on column prc_file_attribute.id is 'Record identifier'
/

comment on column prc_file_attribute.file_id is 'File identifier'
/

comment on column prc_file_attribute.container_id is 'Reference to process container.'
/

comment on column prc_file_attribute.characterset is 'Text file characterset'
/

comment on column prc_file_attribute.file_name_mask is 'File name mask (regular expression).'
/

comment on column prc_file_attribute.name_format_id is 'File name generation algorithm identifier.'
/

comment on column prc_file_attribute.upload_empty_file is 'Instruction to upload empty file'
/

comment on column prc_file_attribute.location is 'URL to store/get file'
/

comment on column prc_file_attribute.xslt_source is 'XML transformation definition in XSLT format.'
/

comment on column prc_file_attribute.converter_class is 'Java handler for converting files.'
/

comment on column prc_file_attribute.is_tar is 'File is a Tape ARchive'
/

comment on column prc_file_attribute.is_zip is 'File is a ZIP archive'
/

comment on column prc_file_attribute.inst_id is 'Institution identifier'
/
alter table prc_file_attribute add (
    load_priority      number(4)
  , sign_transfer_type varchar2(8)
  , encrypt_plugin     varchar2(200)
)
/

comment on column prc_file_attribute.load_priority is 'Priority of file loading'
/

comment on column prc_file_attribute.sign_transfer_type is 'File signature transfer type'
/

comment on column prc_file_attribute.encrypt_plugin is 'File encryption plugin'
/

alter table prc_file_attribute add ignore_file_errors number(1)
/

comment on column prc_file_attribute.ignore_file_errors is 'Continue processing of next files if error occured in current file'
/
alter table prc_file_attribute add location_id number(4)
/
comment on column prc_file_attribute.location_id is 'Link to prc_directory table'
/
alter table prc_file_attribute add parallel_degree number(4)
/
comment on column prc_file_attribute.parallel_degree is 'File loading parallel degree'
/
alter table prc_file_attribute add is_file_name_unique number(1)
/
comment on column prc_file_attribute.is_file_name_unique is 'Check uniqueness of the name of the uploaded file (0 - No, 1 - Yes)'
/
comment on column prc_file_attribute.report_id is 'Reference to report ID'
/
comment on column prc_file_attribute.report_template_id is 'Reference to template report ID'
/
alter table prc_file_attribute add is_file_required number(1)
/
comment on column prc_file_attribute.is_file_required is 'Loaded file is required (0 - No, 1 - Yes)'
/

alter table prc_file_attribute add (is_cleanup_data number(1))
/
comment on column prc_file_attribute.is_cleanup_data is 'If 1 then data in prc_file_raw_data, prc_session_file - file_contents needs to be deleted, if 0 - data must not be deleted'
/

alter table prc_file_attribute nologging
/
alter table prc_file_attribute add queue_identifier varchar2(200)
/
comment on column prc_file_attribute.queue_identifier is 'Message queue identifier'
/

alter table prc_file_attribute add ( time_out    number(8))
/
comment on column prc_file_attribute.time_out is 'Callback timeout for SVFE response (in seconds)'
/

alter table prc_file_attribute add(port varchar2(5))
/
comment on column prc_file_attribute.time_out is 'Port for opening file'
/

comment on column prc_file_attribute.time_out is 'Callback timeout for SVFE response (in seconds)'
/
comment on column prc_file_attribute.port is 'Port for opening file'
/

alter table prc_file_attribute add(line_separator varchar2(20))
/
comment on column prc_file_attribute.line_separator is 'Line separator'
/

alter table prc_file_attribute add(password_protect number(1))
/
comment on column prc_file_attribute.password_protect is 'File protection flag - yes/no'
/
alter table prc_file_attribute add (file_merge_mode varchar2(8))
/
comment on column prc_file_attribute.file_merge_mode is 'File merge mode (dictionary FMMD). NULL is equivalent to code "FMMDNMRG"'
/
