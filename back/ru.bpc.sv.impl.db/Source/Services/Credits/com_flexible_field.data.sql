insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (10003744, 'ENTTINVC', NULL, 'CRD_EXTRA_MAD', 'DTTPNMBR', 'FM000000000000000000.0000', NULL, 1, 9999, NULL)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (10003745, 'ENTTINVC', NULL, 'CRD_EXTRA_DUE_DATE', 'DTTPDATE', 'yyyymmdd', NULL, 1, 9999, NULL)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (10003792, 'ENTTACCT', NULL, 'CRD_SKIP_MAD_DATE', 'DTTPDATE', 'yyyymmdd', NULL, 1, 9999, NULL)
/
delete from com_flexible_field where id = 10003744
/
delete from com_flexible_field where id = 10003745
/
delete from com_flexible_field where id = 10003792
/
