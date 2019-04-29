create table aut_resp_code (
    id                number(4)
  , seqnum            number(4)
  , resp_code         varchar2(8)
  , is_reversal       number(1)
  , proc_type         varchar2(8)
  , auth_status       varchar2(8)
  , proc_mode         varchar2(8)
  , status_reason     varchar2(8)
  , oper_type         varchar2(8)
  , msg_type          varchar2(8)
  , priority          number(4)
)
/
comment on table aut_resp_code is 'Response codes and corresponding parameters'
/
comment on column aut_resp_code.id is 'Record identifier'
/
comment on column aut_resp_code.seqnum is 'Sequence number. Describe data version.'
/
comment on column aut_resp_code.resp_code is 'Response code'
/
comment on column aut_resp_code.is_reversal is 'Reversal indicator'
/
comment on column aut_resp_code.proc_type is 'Processing type (AUPT key)'
/
comment on column aut_resp_code.auth_status is 'Authorization status (AUST key)'
/
comment on column aut_resp_code.proc_mode is 'Processing mode (AUPM key)'
/
comment on column aut_resp_code.status_reason is 'Status reason (AUSR key)'
/
comment on column aut_resp_code.oper_type is 'Operation type'
/
comment on column aut_resp_code.msg_type is 'Message type'
/
comment on column aut_resp_code.priority is 'Priority'
/
alter table aut_resp_code add is_completed varchar2(8)
/
comment on column aut_resp_code.is_completed is 'Flag shows if authorization is completed (CMPF key)'
/
alter table aut_resp_code add sttl_type varchar2(8) default '%'
/
comment on column aut_resp_code.sttl_type is 'Settlement type (STTT key)'
/
alter table aut_resp_code add oper_reason varchar2(8)
/
comment on column aut_resp_code.oper_reason is 'Operation reason. Various list of values depends on operation type.'
/