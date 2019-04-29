create table net_card_type_feature (
    id                number(8) not null
    , seqnum          number(4)
    , card_type_id    number(4)
    , card_feature    varchar2(8)
)
/
comment on table net_card_type_feature is 'Card type feature'
/
comment on column net_card_type_feature.id is 'Primary key'
/
comment on column net_card_type_feature.seqnum is 'Data version sequencial number'
/
comment on column net_card_type_feature.card_type_id is 'Card type identifier'
/
comment on column net_card_type_feature.card_feature is 'Card feature (CFCH dictionary)'
/
