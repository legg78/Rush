create table cst_woo_import_f67(
    seq_id                      varchar2(10)
    , bank_code                 varchar2(10)
    , notice_date               varchar2(10)
    , notice_seq                varchar2(10)
    , from_curr                 varchar2(3)
    , to_curr                   varchar2(3)
    , class_code                varchar2(3)
    , branch_code               varchar2(10)
    , exchange_rate             number(22,4)
    , f_exchange_rate           number(22,4)
    , notice_time               varchar2(10)
    , status_code               varchar2(10)
    , import_date               date
    , file_name                 varchar2(100)
)
/
comment on table cst_woo_import_f67 is 'Table contains data import from file 67'
/
comment on column cst_woo_import_f67.bank_code is 'BANK CODE'
/
comment on column cst_woo_import_f67.notice_date is 'Notification'
/
comment on column cst_woo_import_f67.notice_seq is 'Notice'
/
comment on column cst_woo_import_f67.from_curr is 'FROM currency code'
/
comment on column cst_woo_import_f67.to_curr is 'TO Currency Code'
/
comment on column cst_woo_import_f67.class_code is 'Notice Exchange rate classification code'
/
comment on column cst_woo_import_f67.branch_code is 'Branch code'
/
comment on column cst_woo_import_f67.exchange_rate is 'Notice exchange rate'
/
comment on column cst_woo_import_f67.f_exchange_rate is 'Spread application Notice exchange rate'
/
comment on column cst_woo_import_f67.notice_time is 'Notification Time'
/
comment on column cst_woo_import_f67.status_code is 'Status Separator Code'
/
