create table cmn_standard (
    id                    number(4)
    , seqnum              number(4)
    , application_plugin  varchar2(8)
    , standard_type       varchar2(8)
    , resp_code_lov_id    number(4)
    , key_type_lov_id     number(4)
)
/
comment on table cmn_standard is 'Communication statndards. Protocols to communicate with payment networks.'
/
comment on column cmn_standard.id is 'Primary key.'
/
comment on column cmn_standard.seqnum is 'Sequence number. Describe data version.'
/
comment on column cmn_standard.application_plugin is 'Application plugin name.'
/
comment on column cmn_standard.standard_type is 'Standard type. Describe purpose of standard (Network, Terminal).'
/
comment on column cmn_standard.resp_code_lov_id is 'List of values of standard response codes.'
/
comment on column cmn_standard.key_type_lov_id is 'LOV which contains the values of standard key types'
/
