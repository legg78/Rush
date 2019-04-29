create table cst_woo_import_f73(
    seq_id                      varchar2(10)
    , file_date                 varchar2(8)
    , cif_no                    varchar2(10)
    , branch_code               varchar2(10)
    , w_acc_bank_code           varchar2(10)
    , w_acc_num                 varchar2(20)
    , d_acc_bank_code           varchar2(10)
    , d_acc_num                 varchar2(20)
    , d_currency                varchar2(10)
    , d_amount                  number(22,4)
    , brief_content             varchar2(100)
    , work_type                 varchar2(10)
    , err_code                  varchar2(10)
    , import_date               date
    , file_name                 varchar2(100)
)
/
comment on table cst_woo_import_f73 is 'Response Loyalty info'
/
comment on column cst_woo_import_f73.file_date is 'Job Run Date '
/
comment on column cst_woo_import_f73.cif_no is 'CIF no '
/
comment on column cst_woo_import_f73.branch_code is 'Card management branch code '
/
comment on column cst_woo_import_f73.w_acc_bank_code is 'Withdrawal account bank code '
/
comment on column cst_woo_import_f73.w_acc_num is 'Withdrawal account number'
/
comment on column cst_woo_import_f73.d_acc_bank_code is 'Deposit account bank code'
/
comment on column cst_woo_import_f73.d_acc_num is 'Deposit account number  '
/
comment on column cst_woo_import_f73.d_currency is 'Deposit currency code'
/
comment on column cst_woo_import_f73.d_amount is 'Deposit amount '
/
comment on column cst_woo_import_f73.brief_content is 'Brief contents '
/
comment on column cst_woo_import_f73.work_type is 'Work type code '
/
comment on column cst_woo_import_f73.err_code is 'Error code '
/
alter table cst_woo_import_f73 add sv_acct_num varchar2(30)
/
