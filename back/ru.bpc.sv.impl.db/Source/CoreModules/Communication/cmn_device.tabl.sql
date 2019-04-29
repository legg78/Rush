create table cmn_device (
    id                      number(8)
    , seqnum                number(4)
    , communication_plugin  varchar2(8)
    , inst_id               number(4)
)
/
comment on table cmn_device is 'Connected communication devices.'
/
comment on column cmn_device.id is 'Primary key.'
/
comment on column cmn_device.seqnum is 'Sequence number. Describe data version.'
/
comment on column cmn_device.communication_plugin is 'Communication plug-in name.'
/
comment on column cmn_device.inst_id is 'Owner institution identifier.'
/

alter table cmn_device add (is_enabled number(1))
/
comment on column cmn_device.is_enabled is 'Device activity flag.'
/
