create table cst_woo_import_f138(
    seq_id                      varchar2(10)
    , file_date                 varchar2(8)
    , cif_num                   varchar2(12)
    , branch_code               varchar2(10)
    , wdr_bank_code             varchar2(10)
    , wdr_acct_num              varchar2(30)
    , dep_bank_code             varchar2(10)
    , dep_acct_num              varchar2(30)
    , dep_curr_code             varchar2(10)
    , dep_amount                number(22,4)
    , brief_content             varchar2(100)
    , work_type                 varchar2(10)
    , err_code                  varchar2(10)
    , sv_crd_acct               varchar2(30)
    , import_date               date
    , file_name                 varchar2(50)
)
/
comment on table cst_woo_import_f138 is 'Debit Card account level offline fees - received feedback from CBS'
/
comment on column cst_woo_import_f138.seq_id is 'Sequence ID'
/
comment on column cst_woo_import_f138.file_date is 'Job Run Date'
/
comment on column cst_woo_import_f138.cif_num is 'CIF number'
/
comment on column cst_woo_import_f138.branch_code is 'Card management branch code'
/
comment on column cst_woo_import_f138.wdr_bank_code is 'Withdrawal account bank code'
/
comment on column cst_woo_import_f138.wdr_acct_num is 'Withdrawal account number'
/
comment on column cst_woo_import_f138.dep_bank_code is 'Deposit account bank code'
/
comment on column cst_woo_import_f138.dep_acct_num is 'Deposit account number'
/
comment on column cst_woo_import_f138.dep_curr_code is 'Deposit currency code'
/
comment on column cst_woo_import_f138.dep_amount is 'Deposit amount'
/
comment on column cst_woo_import_f138.brief_content is 'Brief contents'
/
comment on column cst_woo_import_f138.work_type is 'Work type code'
/
comment on column cst_woo_import_f138.err_code is 'Error code'
/
comment on column cst_woo_import_f138.sv_crd_acct is 'SV credit account number'
/
comment on column cst_woo_import_f138.import_date is 'Datetime when file was imported into SV'
/
comment on column cst_woo_import_f138.file_name is 'Import file name'
/
alter table cst_woo_import_f138 add (rcn_status number(1))
/
comment on column cst_woo_import_f138.rcn_status is 'Reconciliation status. 0: record failed in CBS, 1: record failed before in CBS but then successful when CBS reprocess, null: record successful'
/
