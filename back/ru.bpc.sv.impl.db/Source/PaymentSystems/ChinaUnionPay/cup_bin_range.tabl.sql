create table cup_bin_range
(
    issuer_iin          varchar2(11)
  , issuer_name         varchar2(60)
  , card_level          varchar2(1)
  , issuing_region      varchar2(4)
  , card_product        varchar2(2)
  , bin_length          number(2)
  , pan_bin             varchar2(12)
  , pan_length          number(2)
  , card_type           varchar2(1)
  , message_type        number(1)
  , billing_currency    number(3)
  , transaction_type    number(13)
  , transaction_channel number(13)
  , network_opened      number(1)
  , valid               number(1)
  , inst_id             number(4)
  , network_id          number(4)
)
/

comment on table cup_bin_range is 'UnionPay Account Range Table. This Table contains the list of valid UnionPay BINs and account range details. The content of this table is replaced as new UnionPay BIN file comes from Edit Package.'
/

comment on column cup_bin_range.issuer_iin is 'Issuer Institute identifier number.'
/
comment on column cup_bin_range.issuer_name is 'Issuer Institute name.'
/
comment on column cup_bin_range.card_level is 'Card level.'
/
comment on column cup_bin_range.issuing_region is 'Issuing region. It contains ''0'' and 3 digits of country code'
/
comment on column cup_bin_range.card_product is 'Card product.'
/
comment on column cup_bin_range.bin_length is 'BIN length.'
/
comment on column cup_bin_range.pan_bin is 'BIN.'
/
comment on column cup_bin_range.pan_length is 'PAN length.'
/
comment on column cup_bin_range.card_type is 'Card Type. C - credit card, D - debit card, P - prepaid card.'
/
comment on column cup_bin_range.message_type is 'Message type. 0 - single message, 1 - dual message.'
/
comment on column cup_bin_range.billing_currency is 'Billing currency.'
/
comment on column cup_bin_range.transaction_type is 'Transaction type.'
/
comment on column cup_bin_range.transaction_channel is 'Transaction channel.'
/
comment on column cup_bin_range.network_opened is 'Network opened.'
/
comment on column cup_bin_range.valid is 'Contains True by default. The value of False allows customers to lock certain BINs.'
/
comment on column cup_bin_range.inst_id is 'ID of the financial institution the record belongs to.'
/
comment on column cup_bin_range.network_id is 'Network identifier - BIN owner.'
/
