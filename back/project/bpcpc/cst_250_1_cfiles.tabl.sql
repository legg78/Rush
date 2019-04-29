create table cst_250_1_cfiles (
    session_file_id   number(16, 0)
  , file_name         varchar2(200 byte)
)
/
comment on table cst_250_1_cfiles is 'Table of uploaded C-files'
/
comment on column cst_250_1_cfiles.session_file_id is 'Identifier of C-file'
/
comment on column cst_250_1_cfiles.file_name is 'Name of C-file'
/
