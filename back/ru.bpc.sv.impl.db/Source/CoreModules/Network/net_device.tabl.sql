create table net_device
(
    device_id          number(8)
  , host_member_id     number(4)
)
/

comment on table net_device is 'Communication devices using by network.'
/

comment on column net_device.device_id is 'Primary key. Communication device identifier.'
/

comment on column net_device.host_member_id is 'Network member identifier (host).'
/