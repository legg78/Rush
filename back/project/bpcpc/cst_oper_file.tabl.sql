create table cst_oper_file (
    id              number(16)
  , oper_id         number(16)
  , session_file_id number(16)
  , upload_oper_id  number(16)
)
/
comment on table cst_oper_file is 'Table of operations uploaded to C and M file'
/
comment on column cst_oper_file.id is 'Primary key'
/
comment on column cst_oper_file.oper_id is 'Identifier of the uploaded operation'
/
comment on column cst_oper_file.session_file_id is 'Identifier of C or M file'
/
comment on column cst_oper_file.upload_oper_id is 'Changed identifier of the uploaded operation'
/
alter table cst_oper_file add (file_type varchar2(8 char))
/
comment on column cst_oper_file.file_type is 'File type'
/
