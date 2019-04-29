create table cmp_card (
    id                      number(16) not null
    , part_key              as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
    , card_number           varchar2(24)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition cmp_card_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))           -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table cmp_card is 'CMP transactions card numbers store.'
/

comment on column cmp_card.id is 'Primary key. Primary key. CMP financial message identifier.'
/
comment on column cmp_card.card_number is 'Card number.'
/
