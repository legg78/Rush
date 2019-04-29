create table cst_woo_batch_time (
    file_id          number(8)
    , from_date      date
    , to_date        date
    , run_type       number(1)
    , run_status     number(1)
    , run_begin      date
    , run_end        date
)
/

comment on table cst_woo_batch_time is 'Batch file run time'
/
comment on column cst_woo_batch_time.file_id is 'file_id reference to table prc_file(id)'
/
comment on column cst_woo_batch_time.from_date is 'Data is get from this date. From_date is updated when file is run'
/
comment on column cst_woo_batch_time.to_date is 'Data is get till this date. To_date is updated when file is run'
/
comment on column cst_woo_batch_time.run_type is '0: File is run every hours, 1: File is run every day, 2: File is run at the first day of month'
/
comment on column cst_woo_batch_time.run_status is '0: Failed, 1: Succeed'
/
comment on column cst_woo_batch_time.run_begin is 'last run begin time'
/
comment on column cst_woo_batch_time.run_end is 'last run end time'
/
