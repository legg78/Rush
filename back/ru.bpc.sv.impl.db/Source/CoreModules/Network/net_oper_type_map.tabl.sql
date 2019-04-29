create table net_oper_type_map (
    id                      number(4)
    , seqnum                number(4)
    , standard_id           number(4)
    , network_oper_type     varchar2(8)
    , priority              number(4)
    , oper_type             varchar2(8)
)
/
comment on table net_oper_type_map is 'Mapping network operation types into internal operation types (sale, cash, funds transfer, voucher etc)'
/
comment on column net_oper_type_map.id is 'Primary key'
/
comment on column net_oper_type_map.seqnum is 'Sequence number. Describe data version'
/
comment on column net_oper_type_map.standard_id is 'Network standard (VISA, MasterCard etc.)'
/
comment on column net_oper_type_map.network_oper_type is 'Network operation type.'
/
comment on column net_oper_type_map.priority is 'Priority'
/
comment on column net_oper_type_map.oper_type is 'Internal operation type.'
/
alter table net_oper_type_map modify (network_oper_type varchar2(20))
/
