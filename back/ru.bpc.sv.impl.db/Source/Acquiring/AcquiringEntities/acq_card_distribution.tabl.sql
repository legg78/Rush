create table acq_card_distribution (
    card_number  varchar2(24)
  , merchant_id  number(8)
  , is_active    number(1)
)
/

comment on table acq_card_distribution is 'Cards distributed my merchants.'
/

comment on column acq_card_distribution.card_number is 'Card number or unique card number hash value.'
/
comment on column acq_card_distribution.merchant_id is 'Merchant identifier.'
/
comment on column acq_card_distribution.is_active is 'Active if card was used in current billing period.'
/
