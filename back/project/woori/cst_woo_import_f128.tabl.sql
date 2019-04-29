create table cst_woo_import_f128(
    seq_id                      varchar2(10)
    , job_date                  varchar2(8)
    , card_num                  varchar2(20)
    , delivery_status           varchar2(10)
    , delivery_type             varchar2(10)
    , import_date               date
    , file_name                 varchar2(100)
)
/

comment on table cst_woo_import_f128 is 'Table contains data import from file 128'
/
comment on column cst_woo_import_f128.seq_id is 'seq_id load from batch file'
/
comment on column cst_woo_import_f128.job_date is 'Job date'
/
comment on column cst_woo_import_f128.card_num is 'Card number'
/
comment on column cst_woo_import_f128.delivery_status is 'Delivery status'
/
comment on column cst_woo_import_f128.delivery_type is 'Delivery type'
/
comment on column cst_woo_import_f128.import_date is 'Import date'
/
comment on column cst_woo_import_f128.file_name is 'File name'
/
