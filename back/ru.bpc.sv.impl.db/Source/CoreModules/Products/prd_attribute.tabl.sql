create table prd_attribute (
    id                    number(8)
    , service_type_id     number(8)
    , parent_id           number(8)
    , attr_name           varchar2(200)
    , data_type           varchar2(8)
    , lov_id              number(4)
    , display_order       number(4)
    , entity_type         varchar2(8)
    , object_type         varchar2(8)
    , definition_level    varchar2(8)
    , is_visible          number(1)
)
/

comment on table prd_attribute is 'List of product attributes'
/
comment on column prd_attribute.id is 'Attribute identifier'
/
comment on column prd_attribute.service_type_id is 'Reference to service type.'
/
comment on column prd_attribute.parent_id is 'Parent group identifier'
/
comment on column prd_attribute.attr_name is 'Attribute system name'
/
comment on column prd_attribute.data_type is 'Data type of attribute'
/
comment on column prd_attribute.lov_id is 'List of possible values'
/
comment on column prd_attribute.display_order is 'Display order'
/
comment on column prd_attribute.entity_type is 'Type of entity, which associated with parameter'
/
comment on column prd_attribute.object_type is 'Object Type of entity, which associated with parameter'
/
comment on column prd_attribute.definition_level is 'Attribute value defining level (Product or Entity, Service, Entity).'
/
comment on column prd_attribute.is_visible is 'Show attribute on user interface (1 - Yes, 0 - No).'
/

