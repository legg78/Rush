create table cst_woo_import_f59(
    seq_id                      varchar2(10)
    , recov_date                varchar2(10)
    , recov_branch_code         varchar2(10)
    , cus_branch_code           varchar2(10)
    , global_id                 varchar2(40)
    , cif_no                    varchar2(10)
    , crd_acc_num               varchar2(40)
    , card_num                  varchar2(40)
    , acc_num                   varchar2(40)
    , request_amount            number(22,4)
    , total_amount              number(22,4)
    , err_code                  varchar2(10)
    , err_content               varchar2(200)
    , import_date               date
    , file_name                 varchar2(100)
)
/
comment on table cst_woo_import_f59                    is 'Table contains data import from file 59 - This is for data verification'
/
comment on column cst_woo_import_f59.seq_id            is 'seq_id load from batch file'
/
comment on column cst_woo_import_f59.recov_date        is  'Date of recovery'
/
comment on column cst_woo_import_f59.recov_branch_code is  'Recovery branch code'
/
comment on column cst_woo_import_f59.cus_branch_code   is  'Member management  branch code'
/
comment on column cst_woo_import_f59.global_id         is  'Global ID'
/
comment on column cst_woo_import_f59.cif_no            is  'CIF no'
/
comment on column cst_woo_import_f59.crd_acc_num       is  'Billing unit code'
/
comment on column cst_woo_import_f59.card_num          is  'card number'
/
comment on column cst_woo_import_f59.acc_num           is  'Account Number'
/
comment on column cst_woo_import_f59.request_amount    is  'Request for withdrawal amount'
/
comment on column cst_woo_import_f59.total_amount      is  'The total amount recovered'
/
comment on column cst_woo_import_f59.err_code          is  'Error code'
/
comment on column cst_woo_import_f59.err_content       is  'Error contents'
/
