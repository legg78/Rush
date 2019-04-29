create table cmn_resp_code(
    id               number(8)
  , seqnum           number(4)
  , standard_id      number(4)
  , resp_code        varchar2(8)
  , device_code_in   varchar2(8)
  , device_code_out  varchar2(8)
  , resp_reason      varchar2(8)
)
/

comment on table cmn_resp_code is 'Communication response code map.'
/

comment on column cmn_resp_code.id is 'Primary key.'
/
comment on column cmn_resp_code.seqnum is 'Sequence number. Describe data version.'
/
comment on column cmn_resp_code.standard_id is 'Reference to communication standard.'
/
comment on column cmn_resp_code.resp_code is 'Internal response code.'
/
comment on column cmn_resp_code.device_code_in is 'Incoming device response code.'
/
comment on column cmn_resp_code.device_code_out is 'Outgoing device response code.'
/
comment on column cmn_resp_code.resp_reason is 'Internal response reason code.'
/
