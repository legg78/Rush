insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10001377, 'SIMPLE', 'REJECT_DISP_MIN_WARN', 'DTTPNMBR', null, 4, null, '9999', null, null, 0, null, null)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10001378, 'SIMPLE', 'CASH_IN_MIN_WARN', 'DTTPNMBR', null, 4, null, '9999', null, null, 0, null, null)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10001379, 'SIMPLE', 'CASH_IN_MAX_WARN', 'DTTPNMBR', null, 4, null, '9999', null, null, 0, null, null)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10002200, 'SIMPLE', 'POWERUP_SERVICE', 'DTTPCHAR', null, 8, null, null, 410, null, 0, null, null)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10002201, 'SIMPLE', 'SUPERVISOR_SERVICE', 'DTTPCHAR', null, 8, null, null, 410, null, 0, null, null)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10002696, 'SIMPLE', 'POS_BATCH_METHOD', 'DTTPCHAR', 0, 1, NULL, 8, 302, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10002697, 'SIMPLE', 'PARTIAL_APPROVAL', 'DTTPNMBR', 0, 1, NULL, NULL, 4, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10002698, 'SIMPLE', 'PURCHASE_AMOUNT', 'DTTPNMBR', 0, 1, NULL, NULL, 4, NULL, 0, NULL, NULL)
/
update app_element set min_length = 8, max_length = 8, max_value = null where id = 10002696
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003078, 'SIMPLE', 'INSTALMENT_SUPPORT', 'DTTPNMBR', 0, 1, NULL, NULL, 4, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003089, 'SIMPLE', 'POS_BATCH_SUPPORT', 'DTTPNMBR', NULL, 1, NULL, NULL, 4, '0', 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003672, 'SIMPLE', 'COMMENT', 'DTTPCHAR', 0, 200, null, null, null, null, 1, null, null)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003655, 'SIMPLE', 'REMOTE_ADDRESS', 'DTTPCHAR', 0, 15, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003656, 'SIMPLE', 'LOCAL_PORT', 'DTTPCHAR', 0, 5, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003657, 'SIMPLE', 'REMOTE_PORT', 'DTTPCHAR', 0, 5, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003658, 'SIMPLE', 'INITIATOR', 'DTTPCHAR', 0, 8, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003659, 'SIMPLE', 'FORMAT', 'DTTPCHAR', 0, 8, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003660, 'SIMPLE', 'KEEP_ALIVE', 'DTTPNMBR', 0, 1, NULL, NULL, 4, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003661, 'SIMPLE', 'MONITOR_CONNECTION', 'DTTPNMBR', 0, 1, NULL, NULL, 4, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003662, 'SIMPLE', 'MULTIPLE_CONNECTION', 'DTTPNMBR', 0, 1, NULL, NULL, 4, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003663, 'COMPLEX', 'TCP_IP_PROTOCOL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003674, 'SIMPLE', 'COMMUN_PLUGIN', 'DTTPCHAR', 5, 8, NULL, NULL, 406, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003675, 'SIMPLE', 'DEVICE_NAME', 'DTTPCHAR', NULL, 200, NULL, NULL, NULL, NULL, 1, NULL, NULL)
/
update app_element set min_length = 5, lov_id = 409 where id = 10003658
/
update app_element set min_length = 5, lov_id = 408 where id = 10003659
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10003946, 'SIMPLE', 'PARTNER_ID_CODE', 'DTTPCHAR', NULL, 6, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004097, 'COMPLEX', 'MERCHANT_CARD', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'ENTTCARD', NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004098, 'SIMPLE', 'CARD_PRODUCT_ID', 'DTTPNMBR', NULL, 8, '1', '99999999', 656, NULL, 0, NULL, NULL)
/
insert into app_element (id, element_type, name, data_type, min_length, max_length, min_value, max_value, lov_id, default_value, is_multilang, entity_type, edit_form) values (10004274, 'SIMPLE', 'MC_ASSIGNED_ID', 'DTTPCHAR', 0, 6, NULL, NULL, NULL, NULL, 0, NULL, NULL)
/
