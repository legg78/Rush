create table frp_auth_card (
    id          number(16)
  , split_hash  number(4)
  , card_number varchar2(24)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                   -- [@skip patch]
subpartition by list (split_hash)                                                     -- [@skip patch]
subpartition template                                                                 -- [@skip patch]
(                                                                                     -- [@skip patch]
    <subpartition_list>                                                               -- [@skip patch]
)                                                                                     -- [@skip patch]
(                                                                                     -- [@skip patch]
    partition frp_auth_card_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                     -- [@skip patch]
******************** partition end ********************/
/

comment on table frp_auth_card is 'Authorization cards security storage.'
/

comment on column frp_auth_card.id is 'Authorization identifier'
/
comment on column frp_auth_card.split_hash is 'Hash value to split processing'
/
comment on column frp_auth_card.card_number is 'Card number.'
/
