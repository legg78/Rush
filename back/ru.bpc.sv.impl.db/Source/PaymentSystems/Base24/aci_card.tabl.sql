create table aci_card (
    id              number(16)
    , card_number   varchar2(24)
)
/

comment on table aci_card is 'Card numbers'
/
comment on column aci_card.id is 'Primary key. BASE24 message identifier.'
/
comment on column aci_card.card_number is 'Card number'
/
