alter table prc_stat add constraint prc_stat_pk primary key (
    session_id
  , thread_number
)
/
alter table prc_stat drop primary key drop index
/
alter table prc_stat add (constraint prc_stat_pk primary key(session_id, thread_number)
/****************** partition start ********************
    using index global
    partition by range (session_id)
(
    partition prc_stat_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
