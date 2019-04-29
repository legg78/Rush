create table acm_role_object (
    id          number(8) not null
  , role_id     number(4) not null
  , entity_type varchar2(8) not null
  , object_id   number(16) not null
)
/
comment on table acm_role_object is 'Role for objects'
/
comment on column acm_role_object.id is 'Id record'
/
comment on column acm_role_object.role_id is 'Id role'
/
comment on column acm_role_object.object_id is 'Id objects'
/
comment on column acm_role_object.entity_type is 'Type of entity'
/
