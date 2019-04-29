create table cmn_tcp_ip (
    id                  number(8)
  , seqnum              number(4)
  , remote_address      varchar2(15)
  , local_port          varchar2(5)
  , remote_port         varchar2(5)
  , initiator           varchar2(8)
  , format              varchar2(8)
  , keep_alive          number(1)
  , is_enabled          number(1)
  , monitor_connection  number(1)
  , multiple_connection number(1)
  )
/

comment on table cmn_tcp_ip is 'TCP/IP protocol connection parameters.'
/

comment on column cmn_tcp_ip.id is 'Primary key. Device identifier.'
/

comment on column cmn_tcp_ip.seqnum is 'Sequence number. Describe data version.'
/

comment on column cmn_tcp_ip.remote_address is 'Remote device address.'
/

comment on column cmn_tcp_ip.local_port is 'Local port number.'
/

comment on column cmn_tcp_ip.remote_port is 'Remote device port number.'
/

comment on column cmn_tcp_ip.initiator is 'Initiator of the connection (Dictionary - CMNI).'
/

comment on column cmn_tcp_ip.format is 'Data transfer format. Define messages length and coding (Dictionary - CMNF).'
/

comment on column cmn_tcp_ip.keep_alive is 'Keep connection alive flag.'
/

comment on column cmn_tcp_ip.is_enabled is 'TCP/IP protocol enabled'
/

comment on column cmn_tcp_ip.monitor_connection is 'Inform the opening / closing the connection.'
/

comment on column cmn_tcp_ip.multiple_connection is 'Multiple connection allowed (1  - Yes, 0 - No)'
/