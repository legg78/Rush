create table cst_woo_import_f127(
    seq_id                      varchar2(10)
    , job_date                  varchar2(8)
    , card_num                  varchar2(20)
    , delivery_status           varchar2(10)
    , import_date               date
    , file_name                 varchar2(100)
)
/

comment on table cst_woo_import_f127 is 'Table contains data import from file 127'
/
comment on column cst_woo_import_f127.seq_id is 'seq_id load from batch file'
/
comment on column cst_woo_import_f127.job_date is 'Job date'
/
comment on column cst_woo_import_f127.card_num is 'Card number'
/
comment on column cst_woo_import_f127.delivery_status is 'Delivery status'
/
comment on column cst_woo_import_f127.import_date is 'Import date'
/
comment on column cst_woo_import_f127.file_name is 'File name'
/
