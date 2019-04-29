create table vis_money_transfer (
    id                   number(12)
  , pay_fee              number(12)
  , dst_bin              varchar2(6)
  , src_bin              varchar2(6)
  , trans_type           varchar2(1)
  , network_id           number(4)
  , an_format            varchar2(1)
  , origination_date     date
  , pay_amount           number(12)
  , pay_currency         varchar2(3)
  , src_amount           number(12)
  , src_currency         varchar2(3)
  , orig_ref_number      varchar2(12)
  , benef_ref_number     varchar2(6)
  , service_code         varchar2(2)
  , transfer_code        varchar2(8)
  , sendback_reason_code varchar2(5)
  , authorization_code   varchar2(6)
  , market_ind           varchar2(1)
  , dst_inst_id          number(4)
  , src_inst_id          number(4)
)
/

comment on table vis_money_transfer is 'VISA Financial Messages Table. This contains VISA financial records TC 09, 19.'
/

comment on column vis_money_transfer.id is 'Primary Key.'
/

comment on column vis_money_transfer.pay_fee is 'Interchange Fee Amount in Payment Currency'
/

comment on column vis_money_transfer.dst_bin is 'Destination BIN'
/

comment on column vis_money_transfer.src_bin is 'Source BIN'
/

comment on column vis_money_transfer.trans_type is 'Transaction Type P = Presentment S = Sendback N = Notification (ePay only)'
/

comment on column vis_money_transfer.network_id is 'Network ID'
/

comment on column vis_money_transfer.an_format is 'Account Number Format A = ISO Format Card Account Number B = Visa ePay transaction C = Other (other value, or no account number at all)'
/

comment on column vis_money_transfer.origination_date is 'Origination Date (YYMMDD)'
/

comment on column vis_money_transfer.pay_amount is 'Destination Amount in Billing Currency'
/

comment on column vis_money_transfer.pay_currency is '3 - digit Destination Currency ISO alpha code'
/

comment on column vis_money_transfer.src_amount is 'Amount Transaction (Source Amount) Matched to posting file field 3'
/

comment on column vis_money_transfer.src_currency is 'Source Currency Code'
/

comment on column vis_money_transfer.orig_ref_number is 'Originator''s Reference Number'
/

comment on column vis_money_transfer.benef_ref_number is 'Beneficiary''s Reference Number'
/

comment on column vis_money_transfer.service_code is 'Service Code.'
/

comment on column vis_money_transfer.transfer_code is 'Money Transfer Reason Code. '
/

comment on column vis_money_transfer.sendback_reason_code is 'Sendback Reason Code.'
/

comment on column vis_money_transfer.authorization_code is 'Authorization (Approval) Code'
/

comment on column vis_money_transfer.market_ind is 'Market Indicator Space = Standard Visa ePay A = Money Transfer G = Government Service Visa ePay'
/

comment on column vis_money_transfer.dst_inst_id is 'ID of the destination financial institution the record belongs to. '
/

comment on column vis_money_transfer.src_inst_id is 'ID of the source financial institution the record belongs to.'
/
