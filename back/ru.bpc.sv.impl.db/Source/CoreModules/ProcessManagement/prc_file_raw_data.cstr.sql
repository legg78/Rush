alter table prc_file_raw_data add constraint prc_file_raw_data_pk primary key (
    session_file_id
    , record_number
)
/
alter table prc_file_raw_data drop primary key drop index
/
alter table prc_file_raw_data add (constraint prc_file_raw_data_pk primary key(session_file_id, record_number)
/****************** partition start ********************
    using index global
    partition by range (session_file_id)
(
    partition prc_file_raw_data_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
