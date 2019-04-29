insert into acm_privilege (id, name, section_id, module_code, is_active) values (1445, 'RUN_REPORT', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1459, 'SET_REPORT_STATUS', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1460, 'ADD_REPORT', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1461, 'MODIFY_REPORT', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1462, 'REMOVE_REPORT', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1463, 'VIEW_REPORT', 1493, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1464, 'VIEW_REPORT_PARAMETERS', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1465, 'VIEW_REPORT_RUNS', 1513, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1466, 'VIEW_REPORT_RUN_PARAMETERS', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1470, 'ADD_REPORT_PARAMETER', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1471, 'MODIFY_REPORT_PARAMETER', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1472, 'REMOVE_REPORT_PARAMETER', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1646, 'ADD_REPORT_BANNER', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1647, 'MODIFY_REPORT_BANNER', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1648, 'REMOVE_REPORT_BANNER', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1649, 'VIEW_REPORT_BANNER', 1614, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1650, 'ADD_REPORT_TEMPLATE', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1651, 'MODIFY_REPORT_TEMPLATE', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1652, 'REMOVE_REPORT_TEMPLATE', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1653, 'VIEW_REPORT_TEMPLATE', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1985, 'ADD_TAG', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1986, 'EDIT_TAG', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1987, 'REMOVE_TAG', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1988, 'VIEW_TAG', 2275, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000004, 'SHOW_REPORT_DOCUMENTS', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000005, 'VIEW_REPORT_PRINT_FORM_DOCUMENT', NULL, 'RPT', 1)
/
update ACM_PRIVILEGE set section_id = 2289 where id = 10000005
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000405, 'VIEW_TAG_OPERATIONS', NULL, 'RPT', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000539, 'VIEW_REPORTS_CONSTRUCTOR', 2418, 'RTP', 1)
/
update acm_privilege set module_code = 'RPT' where id = 10000539
/
