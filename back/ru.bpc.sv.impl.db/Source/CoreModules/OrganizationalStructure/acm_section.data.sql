insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2427, 1036, 'OST', 'applications|list_inst_apps', 'page', 1, 50, 'MbApplicationsSearch')
/
update acm_section set module_code = 'OST', display_order = 30 where id = 2427
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2454, 1036, 'OST', 'orgStruct|actions', 'page', 1, 50, 'MbOrgStructActions')
/
