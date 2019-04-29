alter table aup_svip add constraint aup_svip_pk primary key ( auth_id, tech_id, entity_type, object_id, message_name )
/


alter table aup_svip add constraint aup_svip_uk unique (tech_id, entity_type, object_id, message_name)
/


