insert into acm_privilege (id, name, section_id, module_code, is_active) values (1337, 'VIEW_HSM_DEVICE', 1086, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1338, 'VIEW_HSM_TCP_IP', null, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1339, 'ADD_HSM_DEVICE', NULL, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1340, 'MODIFY_HSM_DEVICE', NULL, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1341, 'REMOVE_HSM_DEVICE', NULL, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1342, 'ADD_HSM_TCP_IP', NULL, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1343, 'MODIFY_HSM_TCP_IPE', NULL, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1344, 'REMOVE_HSM_TCP_IP', NULL, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1437, 'VIEW_HSM_SELECTIONS', 1473,  'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1438, 'ADD_HSM_SELECTION', NULL,  'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1439, 'MODIFY_HSM_SELECTION', NULL, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1440, 'REMOVE_HSM_SELECTION', NULL, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1441, 'VIEW_HSM_LMK', 1533, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1442, 'ADD_HSM_LMK', null, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1443, 'MODIFY_HSM_LMK', null, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (1444, 'REMOVE_HSM_LMK', null, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000179, 'VIEW_HSM_LOV', NULL, 'HSM', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000211, 'VERIFY_HSM_LMK_VALUE', NULL, 'HSM', 1)
/
update acm_privilege set is_active = 0 where id in (1337, 1441)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000708, 'OPERATION_CREDIT_BALANCE_TRANSFER_MAKER', NULL, 'ISS', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000709, 'OPERATION_CREDIT_BALANCE_TRANSFER_CHECKER', NULL, 'ISS', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000710, 'OPERATION_ROLLBACK_CREDIT_BALANCE_TRANSFER_MAKER', NULL, 'ISS', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000711, 'OPERATION_ROLLBACK_CREDIT_BALANCE_TRANSFER_CHECKER', NULL, 'ISS', 1)
/
