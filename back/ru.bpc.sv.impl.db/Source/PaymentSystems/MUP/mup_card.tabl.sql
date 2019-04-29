create table mup_card (
    id              number(16) not null
    , card_number   varchar2(24)
)
/

comment on table mup_card is 'Card numbers'
/

comment on column mup_card.id is 'Identifier'
/

comment on column mup_card.card_number is 'Card number'
/

