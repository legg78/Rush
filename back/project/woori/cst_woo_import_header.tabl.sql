create table cst_woo_import_header(
    header                      varchar2(6)  
    , job_id                    varchar2(10)
    , process_date              varchar2(8)
    , sequence_id               varchar2(3)
    , total_amount              varchar2(10)
    , total_record              varchar2(10)
    , import_date               date
    , file_name                 varchar2(100) 
)
/

comment on table cst_woo_import_header is 'File import header'
/
comment on column cst_woo_import_header.header is 'File Header identification'
/
comment on column cst_woo_import_header.job_id is 'File Header Job ID'
/
comment on column cst_woo_import_header.process_date is 'File Header Process date - YYYYMMDD'
/
comment on column cst_woo_import_header.sequence_id is 'File Header sequence id'
/
comment on column cst_woo_import_header.sequence_id is 'File Header total amount'
/
comment on column cst_woo_import_header.import_date is 'File import date'
/
comment on column cst_woo_import_header.import_date is 'File name'
/
comment on column cst_woo_import_header.sequence_id is 'File Header sequence id'
/
comment on column cst_woo_import_header.import_date is 'File import date'
/
comment on column cst_woo_import_header.total_amount is 'File Header total amount'
/
comment on column cst_woo_import_header.file_name is 'File name'
/
alter table cst_woo_import_header modify total_amount varchar2(20)
/
