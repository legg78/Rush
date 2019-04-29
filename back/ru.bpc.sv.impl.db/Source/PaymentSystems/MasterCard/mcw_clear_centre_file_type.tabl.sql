create table mcw_clear_centre_file_type
(
  id                    number(4),
  local_clearing_centre varchar2(200),
  file_type             varchar2(3),
  incoming              number(1)
)
/

comment on table mcw_clear_centre_file_type is 'Reference between MC clearing centres and file types'
/
comment on column mcw_clear_centre_file_type.id is 'Identifier'
/
comment on column mcw_clear_centre_file_type.local_clearing_centre is 'MC Local Clearing Centre that process transactions'
/
comment on column mcw_clear_centre_file_type.file_type is 'MC File Type'
/
comment on column mcw_clear_centre_file_type.incoming is 'Incoming indicator'
/
