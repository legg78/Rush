insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10001710, 'SIMPLE', 'PROVIDER_HOST_STATUS', 'DTTPCHAR', 8, 8, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
update app_element set lov_id = 346 where id = 10001710
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10001715, 'SIMPLE', 'OPERTATION_TYPE', 'DTTPCHAR', 5, 8, NULL, NULL, 49, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10001716, 'SIMPLE', 'TERMINAL_ID', 'DTTPNMBR', NULL, 8, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
update app_element set name = 'OPERATION_TYPE' where id = 10001715
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10001995, 'SIMPLE', 'PROVIDER_NUMBER', 'DTTPCHAR', NULL, 200, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10002066, 'SIMPLE', 'PAYMENT_PURPOSE_NUMBER', 'DTTPCHAR', 0, 200, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003366, 'SIMPLE', 'TEMPLATE_STATUS', 'DTTPCHAR', 5, 8, NULL, NULL, 563, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003367, 'SIMPLE', 'ATTEMPT_COUNT', 'DTTPNMBR', 0, 4, '0', '99', NULL, NULL, 0, NULL, NULL)
/

