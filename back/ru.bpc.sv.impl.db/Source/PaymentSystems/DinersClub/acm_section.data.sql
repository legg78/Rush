update acm_section set is_visible=0 where id in (2365, 2370, 2362)
/
update acm_section set is_visible=1 where id=2363
/
update acm_section set is_visible=1 where id=2364
/
delete acm_section where id = 2389
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2389, 2361, NULL, 'din|files', 'page', 1, 6, 'MbDinFilesSearch')
/
delete acm_section where id = 2390
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2390, 2361, NULL, 'din|financial_messages', 'page', 1, 7, 'MbDinFinMessagesSearch')
/

