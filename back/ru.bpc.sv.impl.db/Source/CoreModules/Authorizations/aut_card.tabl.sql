create table aut_card (
    auth_id             number(16)
    , part_key          as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , split_hash        number(4)
    , card_number       varchar2(24)
    , dst_card_number   varchar2(24)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
subpartition by list (split_hash)                                                        -- [@skip patch]
subpartition template                                                                    -- [@skip patch]
(                                                                                        -- [@skip patch]
    <subpartition_list>                                                                  -- [@skip patch]
)                                                                                        -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aut_card_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))           -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table aut_card is 'card numbers are stored here'
/
comment on column aut_card.auth_id is 'authorization id'
/
comment on column aut_card.split_hash is 'hash value to split further processing'
/
comment on column aut_card.card_number is 'card number'
/
comment on column aut_card.dst_card_number is 'destination card number'
/
