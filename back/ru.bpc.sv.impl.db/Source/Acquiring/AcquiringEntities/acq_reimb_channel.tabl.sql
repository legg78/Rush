create table acq_reimb_channel
(
    id                  number(4)
  , seqnum              number(4)
  , channel_number      varchar2(200)
  , payment_mode        varchar2(8)
  , currency            varchar2(3)
  , inst_id             number(4)
)
/

comment on table acq_reimb_channel is 'Reimbursement channels. Describe interfaces for sending reimburstment data.'
/

comment on column acq_reimb_channel.id is 'Primary key'
/
comment on column acq_reimb_channel.seqnum is 'Sequence number. Describe data version.'
/
comment on column acq_reimb_channel.channel_number is 'External number of channel. Correspondent account in bank.'
/
comment on column acq_reimb_channel.payment_mode is 'Payment mode. Define format and way of reimbursement sending. Linked with process file type.'
/
comment on column acq_reimb_channel.currency is 'Currency code of channel. Channel could receive only operations in that cyrrency.'
/
comment on column acq_reimb_channel.inst_id is 'Institution identifier.'
/
