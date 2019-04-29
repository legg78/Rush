create table amx_card (
    id                      number(16) not null
    , card_number           varchar2(24)        
)
/
comment on table amx_card is 'AMX transactions card numbers store.'
/
comment on column amx_card.id is 'Primary key. Primary key. AMX financial message identifier.'
/
comment on column amx_card.card_number is 'Card number.'
/

--update--
comment on column amx_card.id is 'Primary key. AMX financial message identifier'
/
comment on column amx_card.card_number is 'Card number'
/

