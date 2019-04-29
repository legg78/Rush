create table jcb_card (
    id              number(16) not null
    , card_number   varchar2(24)
)
/

comment on table jcb_card is 'Card numbers'
/

comment on column jcb_card.id is 'Identifier'
/

comment on column jcb_card.card_number is 'Card number'
/

