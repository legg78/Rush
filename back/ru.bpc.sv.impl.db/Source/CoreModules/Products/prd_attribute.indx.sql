create unique index prd_attribute_name_uk on prd_attribute (
    attr_name
)
/
create index prd_attribute_service_type_ndx on prd_attribute (service_type_id, entity_type)
/
