create table din_card(
    id                           number(16)
  , card_number                  varchar2(24)
)
/

comment on table din_card is 'Diners Club transactions card numbers'
/
comment on column din_card.id is 'Primary key. Diners Club financial message identifier'
/
comment on column din_card.card_number is 'Card number'
/
