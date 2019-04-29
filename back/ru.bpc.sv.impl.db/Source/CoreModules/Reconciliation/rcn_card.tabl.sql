create table rcn_card (
    id                        number(16)
  , card_number               varchar2(24)
)
/
comment on table rcn_card is 'Reconciliation cards'
/
comment on column rcn_card.id is 'Record identifier'
/
comment on column rcn_card.card_number is 'Card number'
/
