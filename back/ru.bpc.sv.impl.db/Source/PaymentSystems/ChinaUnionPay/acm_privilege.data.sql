delete acm_privilege where name = 'VIEW_CUP_FIN_MESSAGE'
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000366, 'VIEW_CUP_FIN_MESSAGE', 2336, 'CUP', 1)
/
delete acm_privilege where name = 'VIEW_CUP_SESSION'
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000367, 'VIEW_CUP_SESSION', 2337, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000376, 'VIEW_CUP_INTERCHANGE_FEES', 2349, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000377, 'VIEW_CUP_INTERCHANGE_OPERATIONS', 2350, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000378, 'VIEW_CUP_MODULE_GENERAL_SETTINGS', 2352, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000379, 'VIEW_CUP_AGGREGATION', 2353, 'CUP', 1)
/
delete from acm_privilege where id in (10000376, 10000377, 10000378, 10000379)
/
delete acm_privilege where name = 'VIEW_CUP_FIN_MESSAGE'
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000366, 'VIEW_CUP_FIN_MESSAGE', 2336, 'CUP', 1)
/
delete acm_privilege where name = 'VIEW_CUP_SESSION'
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000367, 'VIEW_CUP_SESSION', 2337, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000376, 'VIEW_CUP_INTERCHANGE_FEES', 2349, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000377, 'VIEW_CUP_INTERCHANGE_OPERATIONS', 2350, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000378, 'VIEW_CUP_MODULE_GENERAL_SETTINGS', 2352, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000379, 'VIEW_CUP_AGGREGATION', 2353, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000401, 'VIEW_CUP_INTERCHANGE_CRITERIAS', 2368, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000408, 'VIEW_CUP_DISPUTES', 2372, 'CUP', 1)
/
delete acm_privilege where name = 'VIEW_CUP_DISPUTES'
/
delete acm_privilege where name = 'VIEW_CUP_SESSION'
/
delete acm_privilege where name = 'VIEW_CUP_MODULE_GENERAL_SETTINGS'
/
delete acm_privilege where name = 'VIEW_CUP_AGGREGATION'
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000445, 'VIEW_CUP_FILES', 2388, 'CUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000450, 'VIEW_CUP_AGGREGATION', 2393, 'CUP', 1)
/
delete from acm_privilege where id = 10000376
/
delete from acm_privilege where id = 10000401
/
