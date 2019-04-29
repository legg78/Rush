create table net_msg_type_map (
    id                  number(4)
    , seqnum            number(4)
    , standard_id       number(4)
    , network_msg_type  varchar2(8)
    , priority          number(4)
    , msg_type          varchar2(8)
)
/
comment on table net_msg_type_map is 'Mapping network message types into internal message types (presentment, chargeback, POS batch etc.).'
/
comment on column net_msg_type_map.id is 'Primary key'
/
comment on column net_msg_type_map.seqnum is 'Sequence number. Describe data version.'
/
comment on column net_msg_type_map.standard_id is 'Network standard (VISA, MasterCard etc.).'
/
comment on column net_msg_type_map.network_msg_type is 'Network message type.'
/
comment on column net_msg_type_map.priority is 'Priority to choose message type.'
/
comment on column net_msg_type_map.msg_type is 'Internal message type.'
/
alter table net_msg_type_map modify (network_msg_type  varchar2(12))
/