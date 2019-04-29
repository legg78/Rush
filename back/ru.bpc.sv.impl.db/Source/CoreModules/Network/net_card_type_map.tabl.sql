create table net_card_type_map (
    id                  number(8)
    , seqnum            number(4)
    , standard_id       number(4)
    , network_card_type varchar2(8)
    , priority          number(4)
    , card_type_id      number(4)
)
/
comment on table net_card_type_map is 'Correspondence card types (products) of payment networks with internal card types dictionary.'
/
comment on column net_card_type_map.id is 'Primary key.'
/
comment on column net_card_type_map.seqnum is 'Sequence number. Describe data version.'
/
comment on column net_card_type_map.standard_id is 'Network standard (VISA, MasterCard etc.).'
/
comment on column net_card_type_map.card_type_id is 'Internal card type.'
/
comment on column net_card_type_map.network_card_type is 'Code describing card type in payment network.'
/
comment on column net_card_type_map.priority is 'Priority to choose card type.'
/
alter table net_card_type_map add (country varchar2(3))
/
comment on column net_card_type_map.country is 'Card country.'
/