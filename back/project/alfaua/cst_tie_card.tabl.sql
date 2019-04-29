create table cst_tie_card(
  id          number(16)
, card_number varchar2(24)
)
/
comment on table cst_tie_card is 'Card numbers'
/
comment on column cst_tie_card.id is 'Identifier'
/
comment on column cst_tie_card.card_number is 'Card number'
/
