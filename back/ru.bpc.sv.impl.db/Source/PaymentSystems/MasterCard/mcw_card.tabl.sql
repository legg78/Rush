create table mcw_card (
    id              number(16) not null
    , part_key      as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd'))  -- [@skip patch]
    , card_number   varchar2(24)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                   -- [@skip patch]
(                                                                                     -- [@skip patch]
    partition mcw_card_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))        -- [@skip patch]
)                                                                                     -- [@skip patch]
******************** partition end ********************/
/

comment on table mcw_card is 'Card numbers'
/

comment on column mcw_card.id is 'Identifier'
/

comment on column mcw_card.card_number is 'Card number'
/

alter table mcw_card add p0014 varchar2(19 char)
/

comment on column mcw_card.p0014 is 'Digital Account Reference Number'
/
