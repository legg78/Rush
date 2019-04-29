create index app_object_appl_id_ndx on app_object(appl_id)
/
create index app_object_entity_type_ndx on app_object(entity_type)
/
create index app_object_object_id_ndx on app_object(object_id)
/
drop index app_object_object_id_ndx
/
create index app_object_object_id_ndx on app_object(object_id, entity_type)
/
