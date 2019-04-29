create table net_device_dynamic (
    device_id           number(8)
    , is_signed_on      number(1)
    , is_connected      number(1)
)
/
comment on table net_device_dynamic is 'Table is used to store dynamic information about devices of network hosts.'
/
comment on column net_device_dynamic.device_id is 'Record identifier'
/
comment on column net_device_dynamic.is_signed_on is 'Flag shows if Sign ON have been done on channel provided by device.'
/
comment on column net_device_dynamic.is_connected is 'Flag that showing that physical connection was established'
/
alter table net_device_dynamic add (is_in_stand_in number(1))
/
comment on column net_device_dynamic.is_in_stand_in is 'Flag that showing that device is in Stand-In mode'
/