create table mcw_abu_acq_msg(
    id              number(16)
  , split_hash      number(4)
  , status          varchar2(8)
  , inst_id         number(4)
  , network_id      number(4)
  , request_date    date
  , file_id         number(16)
  , event_object_id number(16)
  , confirm_file_id number(16)
  , acquirer_ica    varchar2(11)
  , request_type    varchar2(1)
  , merchant_number varchar2(15)
  , merchant_name   varchar2(25)
  , mcc             varchar2(4)
  , error_code_1    varchar2(3)
  , error_code_2    varchar2(3)
  , error_code_3    varchar2(3)
  , error_code_4    varchar2(3)
  , error_code_5    varchar2(3)
  , error_code_6    varchar2(3)
  , error_code_7    varchar2(3)
  , error_code_8    varchar2(3)
)
/

comment on table mcw_abu_acq_msg is 'Acquirer messages (merchants data) exported to MasterCard ABU'
/
comment on column mcw_abu_acq_msg.id is 'Message identifier. Equal to id from evt_event_object. Primary key.'
/
comment on column mcw_abu_acq_msg.split_hash is 'Split hash'
/
comment on column mcw_abu_acq_msg.status is 'Message status'
/
comment on column mcw_abu_acq_msg.inst_id is 'Institution identifier'
/
comment on column mcw_abu_acq_msg.network_id is 'Network identifier'
/
comment on column mcw_abu_acq_msg.request_date is 'Request Date'
/
comment on column mcw_abu_acq_msg.file_id is 'File identifier'
/
comment on column mcw_abu_acq_msg.event_object_id is 'Identifier of event from evt_event_object'
/
comment on column mcw_abu_acq_msg.confirm_file_id is 'Confirmation file identifier if message is rejected'
/
comment on column mcw_abu_acq_msg.acquirer_ica is 'Acquirer''s Mastercard customer ID/ICA'
/
comment on column mcw_abu_acq_msg.request_type is 'Request Type'
/
comment on column mcw_abu_acq_msg.merchant_number is 'Merchant Identifier approved by acquirer (Card Acceptor ID)'
/
comment on column mcw_abu_acq_msg.merchant_name is 'Merchant name approved by the acquirer'
/
comment on column mcw_abu_acq_msg.mcc is 'Card Acceptor Business Code (MCC)'
/
comment on column mcw_abu_acq_msg.error_code_1 is 'Error Code 1'
/
comment on column mcw_abu_acq_msg.error_code_2 is 'Error Code 2'
/
comment on column mcw_abu_acq_msg.error_code_3 is 'Error Code 3'
/
comment on column mcw_abu_acq_msg.error_code_4 is 'Error Code 4'
/
comment on column mcw_abu_acq_msg.error_code_5 is 'Error Code 5'
/
comment on column mcw_abu_acq_msg.error_code_6 is 'Error Code 6'
/
comment on column mcw_abu_acq_msg.error_code_7 is 'Error Code 7'
/
comment on column mcw_abu_acq_msg.error_code_8 is 'Error Code 8'
/
