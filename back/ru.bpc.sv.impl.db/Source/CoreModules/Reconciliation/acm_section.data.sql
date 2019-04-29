insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2419, NULL, NULL, NULL, 'folder', 1, 110, NULL)
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2420, 2419, NULL, 'rcn|conditions', 'page', 1, 10, 'MbRcnConditions')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2421, 2419, NULL, 'rcn|cbs', 'page', 1, 20, 'MbRcnCbs')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2422, 2419, NULL, 'rcn|conditions_atm', 'page', 1, 30, 'MbRcnConditionsATM')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2423, 2419, NULL, 'rcn|reconciliation_atm', 'page', 1, 40, 'MbReconciliationATM')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2425, 2419, 'RCN', 'rcn|host_conditions', 'page', 1, 50, 'MbHostRecConditions')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2426, 2419, 'RCN', 'rcn|host_reconciliations', 'page', 1, 60, 'MbReconciliationHost')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2436, 2419, 'RCN', NULL, 'folder', 1, 10, NULL)
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2437, 2419, 'RCN', NULL, 'folder', 1, 20, NULL)
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2438, 2419, 'RCN', NULL, 'folder', 1, 30, NULL)
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2439, 2419, 'RCN', NULL, 'folder', 1, 40, NULL)
/
update acm_section set parent_id = 2436, module_code = 'RCN', action = 'rcn|cbs_conditions', display_order = 10, managed_bean_name = 'MbRcnConditions' where id = 2420
/
update acm_section set parent_id = 2436, module_code = 'RCN', action = 'rcn|cbs_messages', display_order = 20, managed_bean_name = 'MbRcnMessages' where id = 2421
/
update acm_section set parent_id = 2437, module_code = 'RCN', action = 'rcn|atm_conditions', display_order = 10, managed_bean_name = 'MbRcnConditions' where id = 2422
/
update acm_section set parent_id = 2437, module_code = 'RCN', action = 'rcn|atm_messages', display_order = 20, managed_bean_name = 'MbRcnMessages' where id = 2423
/
update acm_section set parent_id = 2438, module_code = 'RCN', action = 'rcn|host_conditions', display_order = 10, managed_bean_name = 'MbRcnConditions' where id = 2425
/
update acm_section set parent_id = 2438, module_code = 'RCN', action = 'rcn|host_messages', display_order = 20, managed_bean_name = 'MbRcnMessages' where id = 2426
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2440, 2439, 'RCN', 'rcn|sp_conditions', 'page', 1, 10, 'MbRcnConditions')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2441, 2439, 'RCN', 'rcn|sp_messages', 'page', 1, 20, 'MbRcnMessages')
/
insert into acm_section (id, parent_id, module_code, action, section_type, is_visible, display_order, managed_bean_name) values (2442, 2439, 'RCN', 'rcn|sp_parameters', 'page', 1, 30, 'MbRcnParameters')
/
