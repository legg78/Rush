delete acm_section where id = 2335
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2335, 2324, NULL, NULL, 'folder', 1, 20, NULL)
/
delete acm_section where id = 2336
/
insert into acm_section(id, parent_id, action, section_type, is_visible, display_order, managed_bean_name) values(2336, 2335, 'cup|financial_messages', 'page', 1, 10, 'MbCupFinMessagesSearch')
/
delete acm_section where id = 2337
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2337, 2335, NULL, 'cup|sessions', 'page', 1, 20, 'MbCupSessionsSearch')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2349, 2335, NULL, 'interchange|cup_fees', 'page', 1, 21, 'MbInterchangeFee')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2350, 2335, NULL, 'interchange|cup_operations', 'page', 1, 22, 'MbInterchangeOperation')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2352, 2335, NULL, 'cup|params', 'page', 1, 24, 'MbModuleParam')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2353, 2335, NULL, 'aggregation|cup', 'page', 1, 25, 'MbAggregation')
/
delete from acm_section where id in (2349, 2350, 2352, 2353)
/delete acm_section where id = 2335
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2335, 2324, NULL, NULL, 'folder', 1, 20, NULL)
/
delete acm_section where id = 2336
/
insert into acm_section(id, parent_id, action, section_type, is_visible, display_order, managed_bean_name) values(2336, 2335, 'cup|financial_messages', 'page', 1, 10, 'MbCupFinMessagesSearch')
/
delete acm_section where id = 2337
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2337, 2335, NULL, 'cup|sessions', 'page', 1, 20, 'MbCupSessionsSearch')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2349, 2335, NULL, 'interchange|cup_fees', 'page', 1, 21, 'MbInterchangeFee')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2350, 2335, NULL, 'interchange|cup_operations', 'page', 1, 22, 'MbInterchangeOperation')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2352, 2335, NULL, 'cup|params', 'page', 1, 24, 'MbModuleParam')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2353, 2335, NULL, 'aggregation|cup', 'page', 1, 25, 'MbAggregation')
/
update acm_section set display_order=23 where id=2350
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2368, 2335, NULL, 'interchange|cup_fee_criterias', 'page', 1, 22, 'MbInterchangeCriteria')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2372, 2335, NULL, 'cup|disputes', 'page', 1, 26, 'MbCupDispute')
/
update acm_section set is_visible=0 where id=2349
/
update acm_section set is_visible=0 where id=2350
/
update acm_section set is_visible=0 where id=2368
/
update acm_section set is_visible=1 where id=2349
/
update acm_section set is_visible=1 where id=2350
/
update acm_section set is_visible=1 where id=2368
/
delete acm_section where id = 2388
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2388, 2335, NULL, 'cup|files', 'page', 1, 27, 'MbCupFilesSearch')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2393, 2335, NULL, 'cup|process_log', 'page', 1, 28, 'MbModuleProcessLog')
/
delete from acm_section where id = 2349
/
delete from acm_section where id = 2368
/
