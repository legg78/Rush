create table cst_woo_import_f130(
    seq_id                      varchar2(10)
    , agent_code                varchar2(8)
    , virtual_acc               varchar2(20)
    , created_date              varchar2(8)
    , parent_acc                varchar2(20)
    , virtual_acc_type          varchar2(8)
    , import_date               date
    , file_name                 varchar2(100)
)
/

comment on table cst_woo_import_f130 is 'Table contains data import from file 130'
/
comment on column cst_woo_import_f130.seq_id is 'seq_id load from batch file'
/
comment on column cst_woo_import_f130.agent_code is 'Agent code'
/
comment on column cst_woo_import_f130.virtual_acc is 'Virtual account'
/
comment on column cst_woo_import_f130.created_date is 'Created date'
/
comment on column cst_woo_import_f130.parent_acc is 'Parent account code'
/
comment on column cst_woo_import_f130.virtual_acc_type is 'Virtual account type code'
/
comment on column cst_woo_import_f130.import_date is 'Import date'
/
comment on column cst_woo_import_f130.file_name is 'File name'
/
