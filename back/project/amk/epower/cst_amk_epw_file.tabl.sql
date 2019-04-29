create table cst_amk_epw_file
(
    id                  number(8)
  , is_incoming         number(1)
  , network_id          number(4)
  , inst_id             number(4)
  , session_file_id     number(16)
  , total_records       number(16)
  , date_beg            date
  , date_end            date
)
/

comment on table cst_amk_epw_file is 'Clearing files.'
/
comment on column cst_amk_epw_file.id is 'Primary key.'
/
comment on column cst_amk_epw_file.is_incoming is 'Incoming flag.'
/
comment on column cst_amk_epw_file.network_id is 'Network identifier.'
/
comment on column cst_amk_epw_file.inst_id is 'Institution identifier.'
/
comment on column cst_amk_epw_file.session_file_id is 'File object identifier(prc_session_file.id).'
/
comment on column cst_amk_epw_file.total_records is 'total records number.'
/
comment on column cst_amk_epw_file.date_beg is 'Start date.'
/
comment on column cst_amk_epw_file.date_end is 'End date.'
/

