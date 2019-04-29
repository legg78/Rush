create table vis_fee (
    id                  number(16)
  , file_id             number(16)
  , pay_fee             number(12)
  , dst_bin             varchar2(6)
  , src_bin             varchar2(6)
  , reason_code         varchar2(4)
  , country_code        varchar2(3)
  , event_date          date
  , pay_amount          number(12)
  , pay_currency        varchar2(3)
  , src_amount          number(12)
  , src_currency        varchar2(3)
  , message_text        varchar2(70)
  , trans_id            varchar2(15)
  , reimb_attr          varchar2(1)
  , dst_inst_id         number(4)
  , src_inst_id         number(4)
  , funding_source      varchar2(1)
)
/

comment on table vis_fee is 'VISA Financial Messages Table. This contains VISA financial records TC 10, 20.'
/

comment on column vis_fee.id is 'Primary Key.'
/

comment on column vis_fee.file_id is 'Reference to clearing file.'
/

comment on column vis_fee.pay_fee is 'Interchange Fee Amount in Payment Currency'
/

comment on column vis_fee.dst_bin is 'Destination BIN'
/

comment on column vis_fee.src_bin is 'Source BIN'
/

comment on column vis_fee.reason_code is 'Reason code'
/

comment on column vis_fee.country_code is 'Country (3 - digit ISO alpha country code) - converted from 2 - digit VISA code.'
/

comment on column vis_fee.event_date is 'Event Date (MMDD).'
/

comment on column vis_fee.pay_amount is 'Destination Amount in Billing Currency'
/

comment on column vis_fee.pay_currency is '3 - digit Destination Currency ISO alpha code'
/

comment on column vis_fee.src_amount is 'Amount Transaction (Source Amount) Matched to posting file field 3'
/

comment on column vis_fee.src_currency is 'Source Currency Code'
/

comment on column vis_fee.message_text is 'Member Message Text'
/

comment on column vis_fee.trans_id is 'Transaction Identifier (TC 09,19).'
/

comment on column vis_fee.reimb_attr is 'Reimbursement Attribute The field must contain A through Z, or 0 through 9.'
/

comment on column vis_fee.dst_inst_id is 'ID of the destination financial institution the record belongs to.'
/

comment on column vis_fee.src_inst_id is 'ID of the source financial institution the record belongs to.'
/

comment on column vis_fee.funding_source is 'Funding source'
/
alter table vis_fee modify pay_amount number(22,4)
/
alter table vis_fee modify src_amount number(22,4)
/
alter table vis_fee modify pay_fee number(22,4)
/
 