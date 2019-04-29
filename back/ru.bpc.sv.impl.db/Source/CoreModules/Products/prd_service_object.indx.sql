create unique index prd_service_object_uk on prd_service_object (
    service_id
    , entity_type
    , object_id
)
/

create index prd_service_object_ndx on prd_service_object(
    contract_id
  , service_id
)
/
create unique index prd_service_object_obj_srv_uk on prd_service_object (object_id, entity_type, service_id)
/
