create table hsm_tcp_ip (
    id                number(4) not null
    , address         varchar2(15) not null
    , port            varchar2(5) not null
    , max_connection  number(4) not null
)
/
comment on table hsm_tcp_ip is 'TCP/IP protocol parameters of hsm connection.'
/
comment on column hsm_tcp_ip.id IS 'Substitute identifier.'
/
comment on column hsm_tcp_ip.address is 'TCP/IP address of HSM.'
/
comment on column hsm_tcp_ip.port IS 'Port of HSM.'
/
comment on column hsm_tcp_ip.max_connection is 'Quantity of connections supported by HSM'
/