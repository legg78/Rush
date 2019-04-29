create table com_currency
(
  id        number(4),
  seqnum    number(4),
  code      varchar2(3),
  name      varchar2(3),
  exponent  number(4)
)
/

comment on table com_currency is 'This table contains the supported ISO currency codes and their associated currency exponents.'
/

comment on column com_currency.id is 'Primary key.'
/

comment on column com_currency.code is 'ISO currency code.'
/

comment on column com_currency.name is 'ISO alpha currency code.'
/

comment on column com_currency.exponent is 'One-position value representing the real currency exponent for the ISO currencies.'
/

comment on column com_currency.seqnum is 'Sequence number. Describe data version.'
/

