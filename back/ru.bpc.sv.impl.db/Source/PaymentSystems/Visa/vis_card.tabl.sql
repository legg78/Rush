create table vis_card
(
  id           number(16),
  card_number  varchar2(24)
)
/

comment on table vis_card is 'VISA transactions card numbers store.'
/

comment on column vis_card.id is 'Primary key. VISA financial message identifier.'
/

comment on column vis_card.card_number is 'Card number.'
/
