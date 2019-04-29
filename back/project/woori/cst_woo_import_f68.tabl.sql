create table cst_woo_import_f68(
    seq_id              varchar2(10)
  , oper_id             number(16)
  , brief_content       varchar2(100)
  , err_code            varchar2(10)
  , import_date         date
  , file_name           varchar2(50)
)
/
comment on table cst_woo_import_f68 is 'Debit card Base II refunds and Credit adjustments - feedback from CBS (only errors)'
/
comment on column cst_woo_import_f68.seq_id is 'Sequence ID'
/
comment on column cst_woo_import_f68.oper_id is 'Operation ID (opr_operation.id)'
/
comment on column cst_woo_import_f68.brief_content is 'Brief contents'
/
comment on column cst_woo_import_f68.err_code is 'Error code'
/
comment on column cst_woo_import_f68.import_date is 'Datetime when file was imported into SV'
/
comment on column cst_woo_import_f68.file_name is 'Import file name'
/
alter table cst_woo_import_f68 add file_date varchar2(8)
/
alter table cst_woo_import_f68 add cif_num varchar2(12)
/
alter table cst_woo_import_f68 add branch_code varchar2(10)
/
alter table cst_woo_import_f68 add wdr_bank_code varchar2(10)
/
alter table cst_woo_import_f68 add wdr_acct_num varchar2(30)
/
alter table cst_woo_import_f68 add dep_bank_code varchar2(10)
/
alter table cst_woo_import_f68 add dep_acct_num varchar2(30)
/
alter table cst_woo_import_f68 add dep_curr_code varchar2(3)
/
alter table cst_woo_import_f68 add dep_amount number(22,4)
/
alter table cst_woo_import_f68 add work_type varchar2(10)
/
alter table cst_woo_import_f68 add sv_crd_acct varchar2(30)
/
comment on column cst_woo_import_f68.file_date is 'Job Run Date'
/
comment on column cst_woo_import_f68.cif_num is 'CIF number'
/
comment on column cst_woo_import_f68.branch_code is 'Card management branch code'
/
comment on column cst_woo_import_f68.wdr_bank_code is 'Withdrawal account bank code'
/
comment on column cst_woo_import_f68.wdr_acct_num is 'Withdrawal account number'
/
comment on column cst_woo_import_f68.dep_bank_code is 'Deposit account bank code'
/
comment on column cst_woo_import_f68.dep_acct_num is 'Deposit account number'
/
comment on column cst_woo_import_f68.dep_curr_code is 'Deposit currency code'
/
comment on column cst_woo_import_f68.dep_amount is 'Deposit amount'
/
comment on column cst_woo_import_f68.work_type is 'Work type code'
/
comment on column cst_woo_import_f68.sv_crd_acct is 'SV credit account number'
/
