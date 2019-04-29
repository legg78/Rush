create table cst_woo_import_f79(
    seq_id                      varchar2(10)
    , bank_code                 varchar2(10)
    , cif_no                    varchar2(10)
    , accident_code             varchar2(10)
    , cus_accident_num          varchar2(30)
    , start_date                varchar2(10)
    , end_date                  varchar2(10)
    , free_date                 varchar2(10)
    , employee_num              varchar2(10)
    , release_branch_code       varchar2(10)
    , restrict_branch_code      varchar2(10)
    , reg_branch_code           varchar2(10)
    , reg_employee_num          varchar2(10)
    , reg_content               varchar2(500)
    , is_valid                  varchar2(10)
    , status_code               varchar2(10)
    , import_date               date
    , file_name                 varchar2(100)
)
/

comment on table cst_woo_import_f79 is 'Table contains data import from file 127'
/
comment on column cst_woo_import_f79.seq_id is 'seq_id load from batch file'
/
comment on column cst_woo_import_f79.bank_code is 'Bank code'
/
comment on column cst_woo_import_f79.cif_no is 'CBS customer number'
/
comment on column cst_woo_import_f79.accident_code is 'All accident identification codes of the customer'
/
comment on column cst_woo_import_f79.cus_accident_num is 'All customer accident serial numbers'
/
comment on column cst_woo_import_f79.start_date is 'All accidents valid start date'
/
comment on column cst_woo_import_f79.end_date is 'All accidents valid end date'
/
comment on column cst_woo_import_f79.free_date is 'All accident-Release date'
/
comment on column cst_woo_import_f79.employee_num is 'Remove all accidents Employe number'
/
comment on column cst_woo_import_f79.release_branch_code is 'All accident release branch codes'
/
comment on column cst_woo_import_f79.restrict_branch_code is 'Transaction Restriction branch Code'
/
comment on column cst_woo_import_f79.reg_branch_code is 'Registration branch Code'
/
comment on column cst_woo_import_f79.reg_employee_num is 'Registration Employe number'
/
comment on column cst_woo_import_f79.reg_content is 'All accident registration contents'
/
comment on column cst_woo_import_f79.is_valid is 'Validity yes or no'
/
comment on column cst_woo_import_f79.status_code is 'Status Separator Code'
/
comment on column cst_woo_import_f79.import_date is 'Import date'
/
comment on column cst_woo_import_f79.file_name is 'File name'
/
