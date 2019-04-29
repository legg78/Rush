create table svy_tag_parameter(
    id               number(12)
  , tag_id           number(8)
  , param_id         number(8)
)
/
comment on table svy_tag_parameter is 'Tag parameters stored here.'
/
comment on column svy_tag_parameter.id is 'Record identifier.'
/
comment on column svy_tag_parameter.tag_id is 'Tag identifier.'
/
comment on column svy_tag_parameter.param_id is 'Parameter identifier.'
/
