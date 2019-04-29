create table hsm_connection (
    hsm_device_id     number(4) not null
    , status          varchar2(8) not null
    , connect_number  number(4) not null
    , action          varchar2(8) not null
)
/
comment on table hsm_connection is 'List of HSM connections.'
/
comment on column hsm_connection.hsm_device_id is 'HSM identifier.'
/
comment on column hsm_connection.status is 'Current status of HSM. Available conditions are: normal, communication problem, configuration problem. Valid values are taken from dictionary ''HSMS''.'
/
comment on column hsm_connection.connect_number is 'Number of connection.'
/
comment on column hsm_connection.action is 'Action with HSM (HSMA key)'
/
