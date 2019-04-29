create table cst_woo_import_f65(
    seq_id                      varchar2(10)
    , job_date                  varchar2(8)
    , cif_num                   varchar2(10)
    , branch_code               varchar2(10)
    , w_bank_code               varchar2(10)
    , w_acct_num                varchar2(20)
    , d_bank_code               varchar2(10)
    , d_acct_num                varchar2(20)
    , d_currency                varchar2(3)
    , d_amount                  number(22,4)
    , b_content                 varchar2(100)
    , work_type                 varchar2(10)
    , err_code                  varchar2(10)
    , import_date               date
    , file_name                 varchar2(100)
)
/
comment on table cst_woo_import_f65 is 'Table contains data import from file 65'
/
comment on column cst_woo_import_f65.job_date is 'Job Run Date'
/
comment on column cst_woo_import_f65.cif_num is 'CIF no'
/
comment on column cst_woo_import_f65.branch_code is 'Card management branch code'
/
comment on column cst_woo_import_f65.w_bank_code is 'Withdrawal account bank code'
/
comment on column cst_woo_import_f65.w_acct_num is 'Withdrawal account number'
/
comment on column cst_woo_import_f65.d_bank_code is 'Deposit account bank code'
/
comment on column cst_woo_import_f65.d_acct_num is 'Deposit account number'
/
comment on column cst_woo_import_f65.d_currency is 'Deposit currency code'
/
comment on column cst_woo_import_f65.d_amount is 'Deposit amount'
/
comment on column cst_woo_import_f65.b_content is 'Brief contents'
/
comment on column cst_woo_import_f65.work_type is 'Work type code'
/
comment on column cst_woo_import_f65.err_code is 'Error code'
/
alter table cst_woo_import_f65 add sv_acct_num varchar2(30)
/
