create table tie_card(
  id          number(16)
, card_number VARCHAR2(24)
)
/
comment on table tie_card is 'Card numbers'
/
comment on column tie_card.id is 'Identifier'
/
comment on column tie_card.card_number is 'Card number'
/
