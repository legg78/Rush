insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2341, 2325, NULL, 'interchange|mc_fees', 'page', 1, 40, 'MbInterchangeFee')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2342, 2325, NULL, 'interchange|mc_operations', 'page', 1, 50, 'MbInterchangeOperation')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2343, 2325, NULL, 'mc|process_log', 'page', 1, 51, 'MbModuleSessionLog')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2344, 2325, NULL, 'mc|params', 'page', 1, 52, 'MbModuleParam')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2354, 2325, NULL, 'aggregation|mc', 'page', 1, 53, 'MbIntAggregation')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2366, 2325, NULL, 'interchange|mc_fee_criterias', 'page', 1, 41, 'MbInterchangeCriteria')
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values(2373, 2325, NULL, 'mc|rejects', 'page', 1, 54, 'MbReject')
/
update acm_section set display_order=54 where id=2354
/
update acm_section set display_order=55 where id=2373
/
insert into acm_section(id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2377, 2325, NULL, 'mc|country_regions', 'page', 1, 53, 'MbModuleParam')
/
update acm_section set is_visible=0 where id=2341
/
update acm_section set is_visible=0 where id=2342
/
update acm_section set is_visible=0 where id=2366
/
delete from acm_section where id = 2344
/
delete from acm_section where id = 2377
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2458, 2325, 'MCW', NULL, 'folder', 1, 60, NULL)
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2459, 2458, 'MCW', 'mc|abu|files', 'page', 1, 10, 'MbAbuFilesSearch')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2460, 2458, 'MCW', 'mc|abu|acq_messages', 'page', 1, 20, 'MbAbuAcqMessagesSearch')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2461, 2458, 'MCW', 'mc|abu|iss_messages', 'page', 1, 30, 'MbAbuIssMessagesSearch')
/
update acm_section set display_order = 5 where id = 2458
/
