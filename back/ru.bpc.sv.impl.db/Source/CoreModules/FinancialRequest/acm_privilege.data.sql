delete from acm_privilege where id = 10000458
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000458, 'VIEW_FIN_REQUESTS', 2403, 'FRQ', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000459, 'PROCESS_FIN_REQUESTS', NULL, 'FRQ', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000642, 'CREATE_FEE_COLLECTION_REQUEST', NULL, 'FCL', 1)
/
insert into acm_privilege (id, name, section_id, module_code, is_active) values (10000643, 'GENERATE_FEE_COLLECTION', NULL, 'FCL', 1)
/

update acm_privilege set name = 'FEE_COLLECTION_MAKER' where id = 10000643
/
update acm_privilege set name = 'FEE_COLLECTION_CHECKER' where id = 10000642
/
update acm_privilege set module_code = 'ORQ' where id = 10000458
/
update acm_privilege set module_code = 'ORQ' where id = 10000459
/
