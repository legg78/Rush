create table net_card_type (
    id                  number(4)
    , seqnum            number(4)
    , parent_type_id    number(4)
    , network_id        number(4)
    , is_virtual        number(1)
)
/
comment on table net_card_type is 'List of card types'
/
comment on column net_card_type.id is 'Identifier'
/
comment on column net_card_type.seqnum is 'Sequence number. Describe data version.'
/
comment on column net_card_type.parent_type_id is 'Parent card type identifier'
/
comment on column net_card_type.network_id is 'Network identifier'
/
comment on column net_card_type.is_virtual is 'Indicator that card is virtual'
/
