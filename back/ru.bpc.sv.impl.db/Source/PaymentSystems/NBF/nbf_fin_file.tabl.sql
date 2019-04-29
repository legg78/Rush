create table nbf_fin_file(
    id              number(8,0)
  , is_incoming     number(1,0)
  , network_id      number(4,0)
  , inst_id         number(4,0)
  , session_file_id number(16,0)
  , records_total   number(8,0)
  , date_beg        date
  , date_end        date
)
/

comment on table nbf_fin_file  is 'NBC Fast clearing files'
/   
comment on column nbf_fin_file.id is 'Primary key. Equal to ID in PRC_SESSION_FILE'
/
comment on column nbf_fin_file.is_incoming is 'Incoming flag'
/
comment on column nbf_fin_file.inst_id is 'Institution identifier'
/
comment on column nbf_fin_file.network_id is 'Network identifier'
/
comment on column nbf_fin_file.session_file_id is 'File object identifier(prc_session_file.id)'
/
comment on column nbf_fin_file.records_total is 'Number of Records in file'
/
comment on column nbf_fin_file.date_beg is 'Start date.'
/
comment on column nbf_fin_file.date_end is 'End date.'
/

