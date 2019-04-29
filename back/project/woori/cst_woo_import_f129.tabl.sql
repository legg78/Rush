create table cst_woo_import_f129(
    seq_id                      varchar2(10)
    , overdue_type              varchar2(10)
    , file_date                 varchar2(8)
    , bank_code                 varchar2(10)
    , crd_run_num               varchar2(20)
    , branch_code               varchar2(10)
    , cif_num                   varchar2(10)
    , crd_deli_code             varchar2(10)
    , item_1                    varchar2(100)
    , product_code              varchar2(10)
    , first_deli_date           varchar2(8)
    , deli_start_date           varchar2(8)
    , num_of_deli               varchar2(10)
    , currency_code             varchar2(10)
    , amt_due_princ             number(22,4)
    , interest_accrued_amt      number(22,4)
    , amort_amt                 number(22,4)
    , item_2                    varchar2(100)
    , overdue_date              varchar2(8)
    , deli_month                varchar2(16)
    , days_to_deli              varchar2(16)
    , overdue_interest_rate     number(22,4)
    , import_date               date
    , file_name                 varchar2(100)
)
/

comment on table cst_woo_import_f129 is 'Table contains data import from file 129'
/
comment on column cst_woo_import_f129.seq_id is 'seq_id load from batch file'
/
comment on column cst_woo_import_f129.overdue_type is 'Overdue type'
/
comment on column cst_woo_import_f129.file_date is 'File date from CBS'
/
comment on column cst_woo_import_f129.bank_code is 'Bank Code'
/
comment on column cst_woo_import_f129.crd_run_num is 'Credit run number'
/
comment on column cst_woo_import_f129.branch_code is 'Branch code'
/
comment on column cst_woo_import_f129.cif_num is 'CBS customer number'
/
comment on column cst_woo_import_f129.crd_deli_code is 'Credit delinquency code'
/
comment on column cst_woo_import_f129.item_1 is 'Item noname'
/
comment on column cst_woo_import_f129.product_code is 'Product code'
/
comment on column cst_woo_import_f129.first_deli_date is 'Date of first delinquency'
/
comment on column cst_woo_import_f129.deli_start_date is 'Delinquency start date'
/
comment on column cst_woo_import_f129.num_of_deli is 'Number of delinquencies'
/
comment on column cst_woo_import_f129.currency_code is 'Currency code'
/
comment on column cst_woo_import_f129.amt_due_princ is 'Amount due on principal'
/
comment on column cst_woo_import_f129.interest_accrued_amt is 'Interest accrued amount'
/
comment on column cst_woo_import_f129.amort_amt is 'Amortization amount'
/
comment on column cst_woo_import_f129.item_2 is 'Item noname'
/
comment on column cst_woo_import_f129.overdue_date is 'Overdue date'
/
comment on column cst_woo_import_f129.deli_month is 'Delinquency month'
/
comment on column cst_woo_import_f129.days_to_deli is 'Days to delinquency'
/
comment on column cst_woo_import_f129.overdue_interest_rate is 'Overdue interest rate'
/
comment on column cst_woo_import_f129.import_date is 'Import date'
/
comment on column cst_woo_import_f129.file_name is 'File name'
/
