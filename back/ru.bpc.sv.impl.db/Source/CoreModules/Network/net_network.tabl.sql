create table net_network (
    id                      number(4)
  , seqnum                  number(4)
  , inst_id                 number(4)
  , bin_table_scan_priority number(4)
)
/

comment on table net_network is 'Networks list'
/

comment on column net_network.id is 'Network identifier'
/

comment on column net_network.seqnum is 'Sequential number of record data version'
/

comment on column net_network.inst_id is 'Primary institution associated with network'
/

comment on column net_network.bin_table_scan_priority is 'Order of scaning of bin table for bin'
/