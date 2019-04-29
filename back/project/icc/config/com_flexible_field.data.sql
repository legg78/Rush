delete com_flexible_field where id = 50000001
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000001, 'ENTTPERS', NULL, 'CST_CUSTOMER_EMPLOYMENT_STATUS', 'DTTPCHAR', NULL, 5001, 1, 9999, NULL)
/
delete com_flexible_field where id = 50000002
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000002, 'ENTTPERS', NULL, 'CST_EMPLOYMENT_PERIOD', 'DTTPCHAR', NULL, 5002, 1, 9999, NULL)
/
delete com_flexible_field where id = 50000003
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000003, 'ENTTPERS', NULL, 'CST_RESIDENCE_TYPE', 'DTTPCHAR', NULL, 5003, 1, 9999, NULL)
/
delete com_flexible_field where id = 50000004
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000004, 'ENTTPERS', NULL, 'CST_MARITAL_STATUS_DATE', 'DTTPDATE', 'yyyymmddhh24miss', NULL, 1, 9999, NULL)
/
delete com_flexible_field where id = 50000005
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000005, 'ENTTCUST', NULL, 'CST_ACQUIRED_BY', 'DTTPCHAR', NULL, NULL, 1, 9999, NULL)
/
delete com_flexible_field where id = 50000006
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000006, 'ENTTCUST', NULL, 'CST_INTRODUCED_BY', 'DTTPCHAR', NULL, NULL, 1, 9999, NULL)
/
delete com_flexible_field where id = 50000007
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000007, 'ENTTCUST', NULL, 'CST_COLLECTED_BY', 'DTTPCHAR', NULL, NULL, 1, 9999, NULL)
/
delete com_flexible_field where id = 50000008
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000008, 'ENTTPERS', NULL, 'CST_INCOME_RANGE', 'DTTPCHAR', NULL, 5004, 1, 9999, NULL)
/
delete com_flexible_field where id = 50000009
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000009, 'ENTTPERS', NULL, 'CST_NUMBER_OF_CHILDREN', 'DTTPCHAR', NULL, 5005, 1, 9999, NULL)
/
delete com_flexible_field where id = 50000011
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000011, 'ENTTCUST', NULL, 'CST_NOTES', 'DTTPCHAR', NULL, NULL, 1, 9999, NULL)
/
delete com_flexible_field where id = 50000042
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000042, 'ENTTCUST', NULL, 'CST_COLLECTOR_NAME', 'DTTPCHAR', NULL, NULL, 1, 9999, NULL)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000546, 'ENTTPROD', NULL, 'CST_PRODUCT_AUTOCHANGE_EVENT', 'DTTPCHAR', NULL, 1018, 1, 9999, NULL)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (-50000555, 'ENTTPERS', NULL, 'CST_ICC_MARRIAGE_ANNIVERSARY', 'DTTPDATE', 'yyyymmddhh24miss', NULL, 1, 9999, NULL)
/
update com_flexible_field set lov_id = 509 where id = -50000001 and lov_id = 5001
/
update com_flexible_field set lov_id = 510 where id = -50000002 and lov_id = 5002
/
update com_flexible_field set lov_id = 511 where id = -50000003 and lov_id = 5003
/
update com_flexible_field set lov_id = 512 where id = -50000008 and lov_id = 5004
/
update com_flexible_field set lov_id = 513 where id = -50000009 and lov_id = 5005
/
