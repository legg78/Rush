create table h2h_file(
    id                  number(16)    not null
  , file_type           varchar2(8)
  , file_date           date
  , session_file_id     number(16)
  , proc_date           date
  , is_incoming         number(1)
  , is_rejected         number(1)
  , network_id          number(4)
  , inst_id             number(4)
  , forw_inst_id        number(4)
  , receiv_inst_id      number(4)
  , orig_file_id        number(16)
)
/

comment on table h2h_file is 'H2H XML clearing files. File identification information.'
/
comment on column h2h_file.id is 'Primary key. Sequence.'
/
comment on column h2h_file.is_incoming is 'Incoming flag.'
/
comment on column h2h_file.is_rejected is 'Rejected message flag.'
/
comment on column h2h_file.network_id is 'Network identifier.'
/
comment on column h2h_file.proc_date is 'Creation Date (Processing date).'
/
comment on column h2h_file.inst_id is 'Institution identifier.'
/
comment on column h2h_file.session_file_id is 'File object identifier (prc_session_file.id).'
/
comment on column h2h_file.file_date is 'File date'
/
comment on column h2h_file.file_type is 'File type'
/
comment on column h2h_file.forw_inst_id is 'Forwarding Institution ID'
/
comment on column h2h_file.receiv_inst_id is 'Receiving Institution ID'
/
comment on column h2h_file.orig_file_id is 'Original file identificator'
/
alter table h2h_file add forw_inst_code varchar2(11)
/
comment on column h2h_file.forw_inst_code is 'Forwarding Institution code'
/
alter table h2h_file add receiv_inst_code varchar2(11)
/
comment on column h2h_file.receiv_inst_code is 'Receiving Institution code'
/
alter table h2h_file drop column forw_inst_id
/
alter table h2h_file drop column receiv_inst_id
/
comment on column h2h_file.forw_inst_code is 'Forwarding/originator institution code (external, not internal SV2 inst_id)'
/
comment on column h2h_file.receiv_inst_code is 'Receiving institution code  (external, not internal SV2 inst_id)'
/
