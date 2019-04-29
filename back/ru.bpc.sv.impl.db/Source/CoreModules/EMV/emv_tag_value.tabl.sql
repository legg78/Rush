create table emv_tag_value (
    id             number(8) not null
    , object_id    number(16)
    , entity_type  varchar2(8)
    , tag_id       number(4)
    , tag_value    varchar2(200)
    , profile      varchar2(8)
)
/
comment on table emv_tag_value is 'EMV tag values'
/
comment on column emv_tag_value.id is 'Primary key'
/
comment on column emv_tag_value.object_id is 'Object identifier'
/
comment on column emv_tag_value.entity_type is 'Entity type'
/
comment on column emv_tag_value.tag_id is 'Tag identifier'
/
comment on column emv_tag_value.tag_value is 'Tag value'
/
comment on column emv_tag_value.profile is 'Profile of emv application (epfl dictionary)'
/
