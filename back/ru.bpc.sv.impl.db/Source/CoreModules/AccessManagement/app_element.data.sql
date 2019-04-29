insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003002, 'COMPLEX', 'USER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'ENTTUSER', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003003, 'SIMPLE', 'USER_ID', 'DTTPNMBR', NULL, 8, '1', '99999999', NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003004, 'SIMPLE', 'USER_STATUS', 'DTTPCHAR', 8, 8, NULL, NULL, 1047, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003005, 'COMPLEX', 'USER_INST', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'ENTT0146', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003006, 'COMPLEX', 'USER_AGENT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'ENTT0147', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003007, 'COMPLEX', 'USER_ROLE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'ENTT0145', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003008, 'SIMPLE', 'ROLE_ID', 'DTTPNMBR', NULL, 4, '1', '9999', 1040, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003009, 'SIMPLE', 'ROLE_NAME', 'DTTPCHAR', NULL, 200, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003010, 'SIMPLE', 'IS_ENTIRELY', 'DTTPNMBR', NULL, NULL, NULL, NULL, 4, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003011, 'SIMPLE', 'IS_DEFAULT', 'DTTPNMBR', NULL, NULL, NULL, NULL, 4, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003031, 'SIMPLE', 'PASSWORD_HASH', 'DTTPCHAR', 1, 128, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004368, 'SIMPLE', 'AUTH_SCHEME', 'DTTPCHAR', 5, 8, NULL, NULL, 581, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004369, 'SIMPLE', 'PASSWORD_CHANGE_NEEDED', 'DTTPNMBR', NULL, NULL, 1, 99999999, 4, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004415, 'COMPLEX', 'USER_GROUP', NULL, 0, 1, NULL, NULL, NULL, NULL, 0, 'ENTTAMUG', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004416, 'SIMPLE', 'GROUP_ID', 'DTTPNMBR', 1, 1, '1', '99999999', 706, NULL, 0, 'ENTTAMUG', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004417, 'SIMPLE', 'USER_LINK_FLAG', 'DTTPNMBR', 1, 1, '0', '1', 4, NULL, 0, 'ENTTAMUG', NULL)
/
update app_element set min_value = 0, max_value = 1 where id = 10004369
/
update app_element set max_length = 8 where id = 10004416
/
