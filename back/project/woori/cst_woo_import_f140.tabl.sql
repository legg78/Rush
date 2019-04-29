create table cst_woo_import_f140(
    seq_id              varchar2(10)
  , debit_oper_id       number(16)
  , credit_oper_id      number(16)
  , bank_code           varchar2(10)
  , branch_code         varchar2(10)
  , transaction_date    varchar2(8)
  , debit_gl_account    varchar2(32)
  , debit_amount        number(22,4)
  , credit_gl_account   varchar2(32)
  , credit_amount       number(22,4)
  , import_date         date
  , file_name           varchar2(50)
)
/
comment on table cst_woo_import_f140 is 'GL adjustments - incoming from CBS'
/
comment on column cst_woo_import_f140.seq_id is 'Sequence ID'
/
comment on column cst_woo_import_f140.debit_oper_id is 'Operation ID for debit part (being assigned after operation posting)'
/
comment on column cst_woo_import_f140.credit_oper_id is 'Operation ID for credit part (being assigned after operation posting)'
/
comment on column cst_woo_import_f140.bank_code is 'Bank code'
/
comment on column cst_woo_import_f140.branch_code is 'Agent number (branch code)'
/
comment on column cst_woo_import_f140.transaction_date is 'Transaction date (format: YYYYMMDD)'
/
comment on column cst_woo_import_f140.debit_gl_account is 'Debit GL account number'
/
comment on column cst_woo_import_f140.debit_amount is 'Debit amount'
/
comment on column cst_woo_import_f140.credit_gl_account is 'Credit GL account number'
/
comment on column cst_woo_import_f140.credit_amount is 'Credit amount'
/
comment on column cst_woo_import_f140.import_date is 'Date-time when file was imported into SV'
/
comment on column cst_woo_import_f140.file_name is 'Import file name'
/
