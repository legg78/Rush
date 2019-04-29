create table net_interface
(
    id                      number(4)
  , seqnum                  number(4)
  , host_member_id          number(4)
  , consumer_member_id      number(4)
  , msp_member_id           number(4)
)
/
comment on table net_interface is 'Network interfaces between consumers and hosts'
/
comment on column net_interface.id is 'Record identifier'
/
comment on column net_interface.seqnum is 'Sequential version of record data'
/
comment on column net_interface.host_member_id is 'Network member institution which acts as host'
/
comment on column net_interface.consumer_member_id is 'Network member institution which connects to host'
/
comment on column net_interface.msp_member_id is 'Network service provider member'
/


