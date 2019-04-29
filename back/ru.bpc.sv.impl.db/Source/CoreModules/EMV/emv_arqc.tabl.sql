create table emv_arqc (
    id               number(16) not null
    , seqnum         number(4)
    , object_id      number(16)
    , entity_type    varchar2(8)
    , tag            varchar2(4)
    , tag_order      number(4)
)
/
comment on table emv_arqc is 'Authorization request cryptogram - a cryptogram used for a process called online card authentication.'
/
comment on column emv_arqc.id is 'Authorization request cryptogram identifier'
/
comment on column emv_arqc.seqnum is 'Sequential number of record version'
/
comment on column emv_arqc.object_id is 'Object identifier'
/
comment on column emv_arqc.entity_type is 'Entity type'
/
comment on column emv_arqc.tag is 'Tag name'
/
comment on column emv_arqc.tag_order is 'Tag order'
/
