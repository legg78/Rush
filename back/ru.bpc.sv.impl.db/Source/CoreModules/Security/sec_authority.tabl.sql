create table sec_authority (
    id          number(4)
    , seqnum    number(4)
    , type      varchar2(8)
    , rid       varchar2(10)
)
/
comment on table sec_authority is 'Certificate authority centers'
/
comment on column sec_authority.id is 'Identifier'
/
comment on column sec_authority.seqnum is 'Sequential number of data version'
/
comment on column sec_authority.type is 'Authority type, etc. Visa, MC'
/
comment on column sec_authority.rid is 'Registered application provider identifier'
/
