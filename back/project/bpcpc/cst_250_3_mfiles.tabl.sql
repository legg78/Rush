create table cst_250_3_mfiles(
    session_file_id   number(16, 0)
  , file_name         varchar2(200 byte)
  , file_type         varchar2(8)
)
/
comment on table cst_250_3_mfiles is 'Table of uploaded M-files'
/
comment on column cst_250_3_mfiles.session_file_id is 'Identifier of M-file'
/
comment on column cst_250_3_mfiles.file_name is 'File name'
/
comment on column cst_250_3_mfiles.file_type is 'File type'
/
