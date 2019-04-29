create table nps_card
(
    id                        number(16)
  , card_number               varchar2(19)
)
/

comment on table nps_card is 'NAPAS cards.'
/
comment on column nps_card.id is 'Primary key. Message identifier'
/
comment on column nps_card.card_number is 'Primary Account Number (Card number)'
/
