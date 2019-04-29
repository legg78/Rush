create table way_file
(
    id                  number(16)
  , is_incoming         number(1)
  , is_rejected         number(1)
  , network_id          number(4)
  , sender              varchar2(32)
  , proc_date           date
  , proc_time           varchar2(8)
  , sttl_date           date
  , file_label         varchar2(32)
  , format_version      varchar2(10)
  , file_seq_number     number(10)
  , receiver            varchar2(32)
  , trans_total         number(8)
  , amount_total        number(22,4)
  , inst_id             number(4)
  , session_file_id     number(16)
)
/

comment on table way_file is 'WAY4 XML clearing files. File identification information. When importing, duplication is checked taking into account the following fields of the given aggregate: FileLabel, Sender, Receiver, Creation Date, FileSeqNumber.'
/

comment on column way_file.id is 'Primary key. Sequence.'
/

comment on column way_file.file_label is 'Constant: DOCUMENT.'
/

comment on column way_file.format_version is 'Constant: 2.2'
/

comment on column way_file.file_seq_number is 'File sequence number'
/

comment on column way_file.receiver is 'Receiver bank Member Id'
/

comment on column way_file.trans_total is 'Number of Doc aggregates in file'
/

comment on column way_file.amount_total is 'Sum of all amounts in all Doc aggregates in file'
/

comment on column way_file.is_incoming is 'Incoming flag.'
/

comment on column way_file.is_rejected is 'Rejected message flag.'
/

comment on column way_file.network_id is 'Network identifier.'
/

comment on column way_file.sender is 'Processing BIN. Sender bank Member Id'
/

comment on column way_file.proc_date is 'Creation Date (Processing date).'
/

comment on column way_file.proc_time is 'Processing time.'
/

comment on column way_file.sttl_date is 'Settlement date.'
/

comment on column way_file.inst_id is 'Institution identifier.'
/

comment on column way_file.session_file_id is 'File object identifier (prc_session_file.id).'
/
