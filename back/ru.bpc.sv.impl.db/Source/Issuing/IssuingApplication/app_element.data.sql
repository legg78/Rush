insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003235, 'COMPLEX', 'ACCOUNT_OBJECT_PROPERTY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'ENTTCARD', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003237, 'SIMPLE', 'LINK_PROPERTY_TYPE', 'DTTPCHAR', 8, 8, NULL, NULL, 536, NULL, 0, 'ENTTCARD', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003238, 'SIMPLE', 'LINK_PROPERTY', 'DTTPCHAR', 8, 8, NULL, NULL, 538, NULL, 0, 'ENTTCARD', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003239, 'SIMPLE', 'LINK_PROPERTY_FLAG', 'DTTPNMBR', 1, 1, '0', '1', 4, NULL, 0, 'ENTTCARD', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003444, 'COMPLEX', 'FACILITATOR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004060, 'SIMPLE', 'CUSTOMER_COUNT', 'DTTPNMBR', 1, 4, '1', '9999', NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004061, 'SIMPLE', 'CUSTOMER_STATUS', 'DTTPCHAR', 8, 8, NULL, NULL, 291, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004217, 'SIMPLE', 'INHERIT_PIN_OFFSET', 'DTTPNMBR', 1, 1, '0', '1', 4, '0', 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004364, 'COMPLEX', 'REFERRAL_PROGRAM', NULL, 0, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004365, 'SIMPLE', 'REFERRER_CODE', 'DTTPCHAR', 0, 1, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004366, 'SIMPLE', 'REFERRAL_CODE', 'DTTPCHAR', 0, 1, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
update app_element set max_length = 1, entity_type = 'ENTTCUST' where id = 10004364
/
update app_element set max_length = 200, entity_type = 'ENTTCUST' where id = 10004365
/
update app_element set max_length = 200, entity_type = 'ENTTCUST' where id = 10004366
/
