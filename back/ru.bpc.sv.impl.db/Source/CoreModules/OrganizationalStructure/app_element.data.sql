insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003885, 'COMPLEX', 'INSTITUTION', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'ENTTINST', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003886, 'SIMPLE', 'INSTITUTION_NAME', 'DTTPCHAR', NULL, 200, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003887, 'SIMPLE', 'INSTITUTION_TYPE', 'DTTPCHAR', 5, 8, NULL, NULL, 325, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003888, 'SIMPLE', 'PARENT_INSTITUTION_ID', 'DTTPNMBR', NULL, NULL, '0', '9999', NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003890, 'COMPLEX', 'AGENT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'ENTTAGNT', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003891, 'SIMPLE', 'AGENT_NAME', 'DTTPCHAR', NULL, 200, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003892, 'SIMPLE', 'AGENT_TYPE', 'DTTPCHAR', 5, 8, NULL, NULL, 626, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003893, 'SIMPLE', 'PARENT_AGENT_ID', 'DTTPNMBR', NULL, NULL, '1', '99999999', NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003932, 'SIMPLE', 'INST_ID', 'DTTPNMBR', NULL, 4, '1', '9999', NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003933, 'SIMPLE', 'INSTITUTION_AGENT_ID', 'DTTPNMBR', NULL, 8, '1', '99999999', NULL, NULL, 0, NULL, NULL)
/
update app_element set lov_id = 1 where id = 10003888
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004354, 'SIMPLE', 'INST_STATUS', 'DTTPCHAR', NULL, 8, NULL, NULL, 691, NULL, 0, NULL, NULL)
/
