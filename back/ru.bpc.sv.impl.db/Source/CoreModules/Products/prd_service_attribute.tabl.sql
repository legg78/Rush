create table prd_service_attribute (
    service_id         number(8)
    , attribute_id     number(8)
    , is_visible       number(1)
)
/

comment on table prd_service_attribute is 'Services linked with product attributes'
/
comment on column prd_service_attribute.service_id is 'Reference to service.'
/
comment on column prd_service_attribute.attribute_id is 'Reference to attribute.'
/
comment on column prd_service_attribute.is_visible is 'Show attribute on user interface (1 - Yes, 0 - No).'
/

