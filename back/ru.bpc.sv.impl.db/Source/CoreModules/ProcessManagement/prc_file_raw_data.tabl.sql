create table prc_file_raw_data (
    session_file_id    number(16) not null
    , part_key         as (to_date(substr(lpad(to_char(session_file_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , record_number    number(8) not null
    , raw_data         varchar2(4000)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                       -- [@skip patch]
(                                                                                         -- [@skip patch]
    partition prc_file_raw_data_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                         -- [@skip patch]
******************** partition end ********************/
/

comment on table prc_file_raw_data is 'Uploaded/Downloaded files content splited by rows in raw format.'
/
comment on column prc_file_raw_data.session_file_id is 'File object identifier.'
/
comment on column prc_file_raw_data.record_number is 'Record sequencial number in file.'
/
comment on column prc_file_raw_data.raw_data is 'Row content.'
/
