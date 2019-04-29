create table h2h_card(
    id                 number(16)
  , card_number        varchar2(24)
)
/
comment on table h2h_card is 'Host-to-Host message card numbers'
/
comment on column h2h_card.id is 'Primary key. Host-to-Host financial message identifier'
/
comment on column h2h_card.card_number is 'Card number'
/
