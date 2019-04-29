insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003286, 10000502, 10000513, 'ACC_ACCOUNT_CREDIT_LIMIT_VALUE', 'DTTPNMBR', NULL, 150, 'ENTTLIMT', 'LMTP0402', 'SADLPRDT', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003287, 10000472, 10001743, 'ISS_CARD_TEMPORARY_CREDIT_LIMIT_VALUE', 'DTTPNMBR', NULL, 170, 'ENTTLIMT', 'LMTP0141', 'SADLPRDT', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003289, 10003288, NULL, 'CRD_CUSTOMER_CREDIT_LIMITS', 'DTTPNMBR', NULL, 10, 'ENTTAGRP', NULL, NULL, 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003290, 10003288, 10003289, 'CRD_CUSTOMER_CREDIT_LIMIT_VALUE', 'DTTPNMBR', NULL, 10, 'ENTTLIMT', 'LMTP0901', 'SADLPRDT', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003291, 10003288, 10003289, 'CRD_CUSTOMER_CASH_ADVANCE_LIMIT_VALUE', 'DTTPNMBR', NULL, 20, 'ENTTLIMT', 'LMTP0902', 'SADLPRDT', 0)
/
update prd_attribute set service_type_id = 10003288, parent_id = 10003289, display_order = 50 where id = 10003254
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003328, 10003288, 10003289, 'CUST_CREDIT_LIMIT_EXCH_RATE_TYPE', 'DTTPCHAR', 110, 40, NULL, NULL, 'SADLPRDT', 1)
/
update prd_attribute set id = 10003348 where id = 10003328
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003767, 10003288, NULL, 'CUST_REGISTRATION_FEE', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP0909', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004123, 10003288, NULL, 'CUSTOMER_LOST_CARD_FEE', 'DTTPNMBR', NULL, 50, 'ENTTFEES', 'FETP0910', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004124, 10003288, NULL, 'CUSTOMER_LOST_CARD_LIMIT', 'DTTPNMBR', NULL, 40, 'ENTTLIMT', 'LMTP0906', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004125, 10003288, NULL, 'CUSTOMER_DAMAGED_CARD_LIMIT', 'DTTPNMBR', NULL, 60, 'ENTTLIMT', 'LMTP0907', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004126, 10003288, NULL, 'CUSTOMER_DAMAGED_CARD_FEE', 'DTTPNMBR', NULL, 70, 'ENTTFEES', 'FETP0911', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004361, 10004360, NULL, 'WELCOME_POINTS', 'DTTPNMBR', NULL, 10, 'ENTTFEES', 'FETP0912', 'SADLSRVC', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004362, 10004360, NULL, 'REFERRAL_POINTS', 'DTTPNMBR', NULL, 20, 'ENTTFEES', 'FETP0913', 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004363, 10004360, NULL, 'REWARD_CALCULATION_ALGORITHM', 'DTTPCHAR', 693, 30, NULL, NULL, 'SADLSRVC', 1)
/
update prd_attribute set is_visible = 1 where id = 10004361
/
update prd_attribute set definition_level = 'SADLPRDT' where id = 10004361
/
update prd_attribute set definition_level = 'SADLPRDT' where id = 10004362
/
update prd_attribute set definition_level = 'SADLPRDT' where id = 10004363
/
