insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id) values (10001140, 'ENTTAPPL', NULL, 'APPL_DESCRIPTION', 'DTTPCHAR', NULL, NULL, 1, 9999)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (10003611, 'ENTTADDR', NULL, 'ADDRESS_NOTE', 'DTTPCHAR', NULL, NULL, 1, 9999, NULL)
/
delete from com_flexible_field where id = 10003611
/
