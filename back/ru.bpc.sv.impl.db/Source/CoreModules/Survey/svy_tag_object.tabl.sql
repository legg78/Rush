create table svy_tag_object(
    id               number(12)
  , tag_id           number(8)
  , param_id         number(8)
  , object_id        number(16)
)
/
comment on table svy_tag_object is 'Links between objects and tags stored here.'
/
comment on column svy_tag_object.id is 'Record identifier.'
/
comment on column svy_tag_object.tag_id is 'Tag identifier.'
/
comment on column svy_tag_object.object_id is 'Object identifier.'
/
