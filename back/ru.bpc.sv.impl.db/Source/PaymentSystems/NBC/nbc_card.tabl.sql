create table nbc_card (
  id           number(16),
  card_number  varchar2(24)
)
/

comment on table nbc_card is 'NBC transactions card numbers store.'
/
comment on column nbc_card.id is 'Primary key. NBC financial message identifier.'
/
comment on column nbc_card.card_number is 'Card number.'
/
