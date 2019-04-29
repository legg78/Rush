create table rul_name_base_param (
    id                  number(8)
    , entity_type       varchar2(8)
    , name              varchar2(200)
)
/
comment on table rul_name_base_param is 'List of base parameters depending on entity type for use in name generation'
/
comment on column rul_name_base_param.id is 'Identifier'
/
comment on column rul_name_base_param.entity_type is 'Entity type'
/
comment on column rul_name_base_param.name is 'Base parameter name'
/
