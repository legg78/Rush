create table cmn_device_connection (
    device_id         number(8) not null
    , connect_number  number(4) not null
    , status          varchar2(8) not null
)
/
comment on table cmn_device_connection is 'Table is used to store dynamic information about TCP/IP devices for monitoring purposes.'
/
comment on column cmn_device_connection.device_id is 'Device identifier.'
/
comment on column cmn_device_connection.connect_number is 'Number of connection.'
/
comment on column cmn_device_connection.status is 'Current status of TCP/IP devices. Available conditions are: normal, communication problem, configuration problem.'
/
