create table mcw_abu_iss_msg(
    id                  number(16)
  , split_hash          number(4)
  , status              varchar2(8)
  , inst_id             number(4)
  , network_id          number(4)
  , proc_date           date
  , file_id             number(16)
  , event_object_id     number(16)
  , confirm_file_id     number(16)
  , issuer_ica          varchar2(11)
  , old_card_number     varchar2(19)
  , old_expiration_date date
  , new_card_number     varchar2(19)
  , new_expiration_date date
  , reason_code         varchar2(1)
  , error_code_1        varchar2(3)
  , error_code_2        varchar2(3)
  , error_code_3        varchar2(3)
  , error_code_4        varchar2(3)
  , error_code_5        varchar2(3)
)
/

comment on table mcw_abu_iss_msg is 'Issuer messages (cards data) exported to MasterCard ABU'
/
comment on column mcw_abu_iss_msg.id is 'Message identifier. Equal to id from evt_event_object. Primary key.'
/
comment on column mcw_abu_iss_msg.split_hash is 'Split hash'
/
comment on column mcw_abu_iss_msg.status is  'Message status'
/
comment on column mcw_abu_iss_msg.inst_id is  'Institution identifier'
/
comment on column mcw_abu_iss_msg.network_id is 'Network identifier'
/
comment on column mcw_abu_iss_msg.proc_date is 'Processing date'
/
comment on column mcw_abu_iss_msg.file_id is 'File identifier'
/
comment on column mcw_abu_iss_msg.event_object_id is 'Identifier of event from evt_event_object'
/
comment on column mcw_abu_iss_msg.confirm_file_id is 'Confirmation file identifier if message is rejected'
/
comment on column mcw_abu_iss_msg.issuer_ica is 'Issuer''s Customer ID/ICA Number'
/
comment on column mcw_abu_iss_msg.old_card_number is 'Old Account Number'
/
comment on column mcw_abu_iss_msg.old_expiration_date is 'Old Expiration Date'
/
comment on column mcw_abu_iss_msg.new_card_number is 'New Account Number'
/
comment on column mcw_abu_iss_msg.new_expiration_date is 'New Expiration Date'
/
comment on column mcw_abu_iss_msg.reason_code is 'Reason code'
/
comment on column mcw_abu_iss_msg.error_code_1 is 'Error Code 1'
/
comment on column mcw_abu_iss_msg.error_code_2 is 'Error Code 2'
/
comment on column mcw_abu_iss_msg.error_code_3 is 'Error Code 3'
/
comment on column mcw_abu_iss_msg.error_code_4 is 'Error Code 4'
/
comment on column mcw_abu_iss_msg.error_code_5 is 'Error Code 5'
/
