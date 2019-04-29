create table cst_bnv_napas_fin_file
(
    id                  number(16)
  , is_incoming         number(1)
  , is_returned         number(1)
  , network_id          number(4)
  , proc_bin            varchar2(6)
  , proc_date           date
  , inst_id             number(4)
  , session_file_id     number(16)
  , total_records       number(16)
)
/

comment on table cst_bnv_napas_fin_file is 'NAPAS clearing files.'
/
comment on column cst_bnv_napas_fin_file.id is 'Primary key.'
/
comment on column cst_bnv_napas_fin_file.is_incoming is 'Incoming indicator'
/
comment on column cst_bnv_napas_fin_file.is_returned is 'Returned indicator'
/
comment on column cst_bnv_napas_fin_file.network_id is 'Network identifier'
/
comment on column cst_bnv_napas_fin_file.proc_bin is 'Processing BIN'
/
comment on column cst_bnv_napas_fin_file.proc_date is 'Processing date'
/
comment on column cst_bnv_napas_fin_file.inst_id is 'Institution identifier'
/
comment on column cst_bnv_napas_fin_file.session_file_id is 'File object identifier (prc_session_file.id)'
/
comment on column cst_bnv_napas_fin_file.total_records is 'Records count'
/
alter table cst_bnv_napas_fin_file add (participant_type varchar2(3))
/
comment on column cst_bnv_napas_fin_file.participant_type is 'Participant type: ISS/ACQ/BNB'
/

