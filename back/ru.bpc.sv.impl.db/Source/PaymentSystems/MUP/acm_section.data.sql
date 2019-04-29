insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2395, 2324, NULL, NULL, 'folder', 1, NULL, NULL)
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2396, 2395, NULL, 'interchange|mir_operations', 'page', 1, 10, 'MbInterchangeOperation')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2397, 2395, NULL, 'mir|process_log', 'page', 1, 20, 'MbModuleProcessLog')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2398, 2395, NULL, 'mir|rejects', 'page', 1, 30, 'MbReject')
/
delete acm_section where id = 2401
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2401, 2395, NULL, 'mir|financial_messages', 'page', 1, 15, 'MbMirFinMessagesSearch')
/
delete acm_section where id = 2402
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2402, 2395, NULL, 'mir|files', 'page', 1, 18, 'MbMirFilesSearch')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2449, 2395, 'MUP', 'mir|reports', 'page', 1, 40, 'MbMirReportsSearch')
/
