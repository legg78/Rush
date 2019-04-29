create table svy_parameter_entity(
    id               number(12)
  , seqnum           number(4)
  , entity_type      varchar2(8)
  , param_id         number(8)   
)
/
comment on table svy_parameter_entity is 'List of possible associations between parameters and entity types.'
/
comment on column svy_parameter_entity.id is 'Association identifier. Primary key.'
/
comment on column svy_parameter_entity.seqnum is 'Sequence number. Describe data version.'
/
comment on column svy_parameter_entity.entity_type is 'Business-entity type.'
/
comment on column svy_parameter_entity.param_id is 'Parameter identifier.'
/
