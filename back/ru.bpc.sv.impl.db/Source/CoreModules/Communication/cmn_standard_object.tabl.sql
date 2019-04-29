create table cmn_standard_object (
    id              number(8)
    , entity_type   varchar2(8)
    , object_id     number(16)
    , standard_id   number(4)
    , standard_type varchar2(8)
)
/
comment on column cmn_standard_object.entity_type is 'Entity type'
/
comment on column cmn_standard_object.id is 'Primary key'
/
comment on column cmn_standard_object.object_id is 'Object id'
/
comment on column cmn_standard_object.standard_id is 'Standard'
/
comment on column cmn_standard_object.standard_type is 'Type of standard'
/
comment on table cmn_standard_object is 'Standards assigned to objects'
/


