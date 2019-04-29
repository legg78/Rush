create table cup_card (
    id                      number(16) not null
    , card_number           varchar2(24)        
)
/
comment on table cup_card is 'CUP transactions card numbers store.'
/
comment on column cup_card.id is 'Primary key. Primary key. CUP financial message identifier.'
/
comment on column cup_card.card_number is 'Card number.'
/


