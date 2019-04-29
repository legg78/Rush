create table cst_ap_session
(
    id                  number(8) not null
  , start_date          date
  , end_date            date
  , status              number(1)
  , session_file_id     number(16)
)
/
comment on table cst_ap_session is 'Table contains data of SYNTI, SYNTO and SYNTR files'
/
comment on column cst_ap_session.id is 'Primary key'
/
comment on column cst_ap_session.start_date is 'Start of session day - time is always equal 10:00'
/
comment on column cst_ap_session.end_date is 'End of session day from datagen file. Empty for future record'
/
comment on column cst_ap_session.status is 'Status of session: 0 - close, 1 - active, 2 - future'
/
comment on column cst_ap_session.session_file_id is 'Ref on prc_session_file.id'
/
