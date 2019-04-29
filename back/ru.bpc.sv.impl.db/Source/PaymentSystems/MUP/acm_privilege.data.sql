insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000439, 'VIEW_MIR_SESSION', 2390, 'MIR', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000440, 'VIEW_MIR_INTERCHANGE_OPERATIONS', 2389, 'MIR', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000441, 'VIEW_MIR_REJECTS', 2391, 'MIR', 1)
/
update acm_privilege set module_code='MUP' where id=10000439
/
update acm_privilege set module_code='MUP' where id=10000440
/
update acm_privilege set module_code='MUP' where id=10000441
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000442, 'VIEW_MIR_FIN_MESSAGES', 2401, 'MUP', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000443, 'VIEW_MIR_FILES', NULL, 'MUP', 1)
/
update acm_privilege set section_id=2402 where id=10000443
/
update acm_privilege set section_id = 2397 where id = 10000439
/
update acm_privilege set section_id = 2396 where id = 10000440
/
update acm_privilege set section_id = 2398 where id = 10000441
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000695, 'VIEW_MIR_REPORTS', 2449, 'MUP', 1)
/
