create table hsm_selection (
    id                number(4) not null
    , seqnum          number(4) not null
    , hsm_device_id   number(4) not null
    , action          varchar2(8) not null
    , inst_id         number(4) not null
    , mod_id          number(4)
    , max_connection  number(4) not null
    , firmware        varchar2(8) not null
)
/
comment on table hsm_selection is 'Selection to perform HSM action'
/
comment on column hsm_selection.id is 'Selection identifier'
/
comment on column hsm_selection.seqnum is 'Sequential number of record version'
/
comment on column hsm_selection.hsm_device_id is 'HSM identifier'
/
comment on column hsm_selection.action is 'Action with HSM (HSMA key)'
/
comment on column hsm_selection.inst_id is 'Owner institution identifier'
/
comment on column hsm_selection.mod_id is 'Modifier identifier'
/
comment on column hsm_selection.max_connection is 'Quantity of connections supported by HSM'
/
comment on column hsm_selection.firmware is 'HSM device firmware (HSMF key)'
/
