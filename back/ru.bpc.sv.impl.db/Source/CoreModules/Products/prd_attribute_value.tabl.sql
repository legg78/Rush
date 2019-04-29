create table prd_attribute_value (
    id                    number(12)
    , service_id          number(8)
    , object_id           number(16)
    , entity_type         varchar2(8)
    , attr_id             number(8)
    , mod_id              number(4)
    , start_date          date
    , end_date            date
    , register_timestamp  timestamp(6)
    , attr_value          varchar2(200)
    , split_hash          number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/

comment on table prd_attribute_value is 'Values of issuing product attributes'
/
comment on column prd_attribute_value.id is 'Primary key.'
/
comment on column prd_attribute_value.service_id is 'Service which is own attribute value.'
/
comment on column prd_attribute_value.object_id is 'Object identifier which attribute relates to'
/
comment on column prd_attribute_value.entity_type is 'Entity type'
/
comment on column prd_attribute_value.attr_id is 'Attribute identifier'
/
comment on column prd_attribute_value.mod_id is 'Modifier identifier'
/
comment on column prd_attribute_value.start_date is 'Date when value becomes effective'
/
comment on column prd_attribute_value.end_date is 'Date when value expires'
/
comment on column prd_attribute_value.register_timestamp is 'Timestamp of registration'
/
comment on column prd_attribute_value.attr_value is 'Attribute value'
/
comment on column prd_attribute_value.split_hash is 'Hash value to split processing'
/
alter table prd_attribute_value enable row movement
/
comment on column prd_attribute_value.split_hash is 'Hash value to split processing which is calculated by entity_type/object_id'
/
