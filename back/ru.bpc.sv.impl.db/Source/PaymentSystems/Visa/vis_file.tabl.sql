create table vis_file
(
    id                  number(16)
  , is_incoming         number(1)
  , is_returned         number(1)
  , network_id          number(4)
  , proc_bin            varchar2(6)
  , proc_date           date
  , sttl_date           date
  , release_number      varchar2(3)
  , test_option         varchar2(4)
  , security_code       varchar2(8)
  , visa_file_id        varchar2(3)
  , batch_total         number(8)
  , monetary_total      number(8)
  , tcr_total           number(8)
  , trans_total         number(8)
  , src_amount          number(22,4)
  , dst_amount          number(22,4)
  , inst_id             number(4)
)
/

comment on table vis_file is 'VISA clearing files.'
/

comment on column vis_file.id is 'Primary key. Equal to ID in PRC_SESSION_FILE.'
/

comment on column vis_file.is_incoming is 'Incoming flag.'
/

comment on column vis_file.is_returned is 'Rejected message flag.'
/

comment on column vis_file.network_id is 'Network identifier.'
/

comment on column vis_file.proc_bin is 'Processing BIN.'
/

comment on column vis_file.proc_date is 'Processing date.'
/

comment on column vis_file.sttl_date is 'Settlement date.'
/

comment on column vis_file.release_number is 'Release number.'
/

comment on column vis_file.test_option is 'Test option.'
/

comment on column vis_file.security_code is 'Security code.'
/

comment on column vis_file.visa_file_id is 'VISA file identifier.'
/

comment on column vis_file.batch_total is 'Total batches in file.'
/

comment on column vis_file.monetary_total is 'Number of Monetary Transactions'
/

comment on column vis_file.tcr_total is 'Number of TCRs'
/

comment on column vis_file.trans_total is 'Number of Transactions'
/

comment on column vis_file.src_amount is 'Source amount.'
/

comment on column vis_file.dst_amount is 'Destination Amount'
/

comment on column vis_file.inst_id is 'Institution identifier.'
/
alter table vis_file add (session_file_id  number(16))
/
comment on column vis_file.session_file_id is 'File object identifier(prc_session_file.id).'
/


alter table vis_file add (is_rejected NUMBER(1))
/
comment on column vis_file.is_returned is 'Returned message flag.'
/
comment on column vis_file.is_rejected is 'Rejected message flag.'
/
comment on column vis_file.id is 'Primary key.'
/
