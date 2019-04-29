insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (-50000902, 10000403, 10000387, 'CST_CFC_REVISED_BUCKET_PERIOD', 'DTTPCHAR', NULL, 9, 'ENTTCYCL', 'CYTP5104', 'SADLOBJT', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (-50000906, 10000403, 10000387, 'CST_CFC_REVISED_BUCKET_VALUE', 'DTTPCHAR', NULL, 8, NULL, NULL, 'SADLOBJT', 0)
/
update prd_attribute set data_type = 'DTTPNMBR' where id = -50000902
/
update prd_attribute set is_visible = 1 where id = 10003871
/
update prd_attribute set is_visible = 1 where id = 10003872
/
update prd_attribute set is_visible = 1 where id = 10003873
/
update prd_attribute set is_visible = 1 where id = 10003746
/
update prd_attribute set is_visible = 1 where id = 10003747
/
update prd_attribute set is_visible = 1 where id = 10003748
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (-50001155, 10000540, NULL, 'CST_CFC_ENABLE_COLLECTION', 'DTTPCHAR', 125, 50, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (-50001162, 10000502, 10000513, 'ACC_TOTAL_OUTSTANDING_THRESHOLD', 'DTTPNMBR', NULL, 166, 'ENTTLIMT', 'LMTP0423', 'SADLPRDT', 1)
/
update prd_attribute set object_type = 'LMTP5423' where id = -50001162
/
update prd_attribute set is_visible = 1 where id = 10004106
/
update prd_attribute set is_visible = 1 where id = 10004107
/
update prd_attribute set is_visible = 1 where id = 10004424
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (-50001245, 10000472, 10000494, 'CST_CFC_POOL_ACC_NUMBER_FORMAT', 'DTTPNMBR', 279, 165, NULL, NULL, 'SADLPRDT', 1)
/
