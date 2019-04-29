create table iss_card_number (
    card_id             number(12 , 0) not null
    , card_number       varchar2(24) not null
)
/
comment on table iss_card_number is 'Card numbers are stored here'
/
comment on column iss_card_number.card_id is 'Card identifier'
/
comment on column iss_card_number.card_number is 'Card number'
/

