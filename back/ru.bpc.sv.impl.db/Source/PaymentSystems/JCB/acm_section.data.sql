insert into ACM_SECTION (ID, PARENT_ID, SECTION_TYPE, IS_VISIBLE) values (2385, 2324, 'folder', 1)
/
insert into ACM_SECTION (ID, PARENT_ID, ACTION, SECTION_TYPE, IS_VISIBLE, DISPLAY_ORDER, MANAGED_BEAN_NAME) values (2386, 2385, 'jcb|process_log', 'page', 1, 10, 'MbModuleProcessLog')
/
insert into ACM_SECTION (ID, PARENT_ID, ACTION, SECTION_TYPE, IS_VISIBLE, DISPLAY_ORDER, MANAGED_BEAN_NAME) values (2387, 2385, 'interchange|jcb_operations', 'page', 1, 20, 'MbInterchangeOperation')
/
delete acm_section where id = 2391
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2391, 2385, NULL, 'jcb|files', 'page', 1, 30, 'MbJcbFilesSearch')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2392, 2385, NULL, 'jcb|financial_messages', 'page', 1, 40, 'MbJcbFinMessagesSearch')
/

