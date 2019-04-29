insert into app_flow (id, seqnum, appl_type, inst_id, template_appl_id) values (2, 1, 'APTPISSA', 9999, 1)
/
insert into app_flow (id, seqnum, appl_type, inst_id, template_appl_id) values (3, 1, 'APTPISSA', 9999, null)
/
insert into app_flow (id, seqnum, appl_type, inst_id, template_appl_id) values (4, 1, 'APTPISSA', 9999, 1)
/
insert into app_flow (id, seqnum, appl_type, inst_id, template_appl_id) values (5, 1, 'APTPISSA', 9999, 1)
/
insert into app_flow (id, seqnum, appl_type, inst_id, template_appl_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id) values (8, 1, 'APTPISSA', 9999, NULL, NULL, NULL, 'ENTTCOMP', 'CNTPCRCR', NULL)
/
insert into app_flow (id, seqnum, appl_type, inst_id, template_appl_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id) values (9, 1, 'APTPISSA', 9999, NULL, NULL, NULL, 'ENTTCOMP', 'CNTPSLPR', NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1001, 1, 'APTPISSA', NULL, 1001, 0, 0, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1002, 1, 'APTPISSA', NULL, 1001, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1003, 1, 'APTPISSA', NULL, 1001, 0, 0, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1004, 1, 'APTPISSA', NULL, 1001, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1005, 1, 'APTPISSA', NULL, 1001, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1006, 1, 'APTPISSA', NULL, 1001, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1007, 1, 'APTPISSA', NULL, 1001, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1008, 1, 'APTPISSA', NULL, 1001, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
update app_flow set id = 1009 where id = 4
/
update app_flow set inst_id = 9999 where id in (1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008)
/
update app_flow set is_customer_exist = 1, is_contract_exist = 1 where id = 1003
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1010, 3, 'APTPISSA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1011, 2, 'APTPISSA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1012, 2, 'APTPISSA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1013, 2, 'APTPISSA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1014, 1, 'APTPISSA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1015, 1, 'APTPISSA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
update app_flow set template_appl_id = null where id = 5
/
update app_flow set is_customer_exist = NULL where id = 1001
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1016, 1, 'APTPISSA', NULL, 9999, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
/
update app_flow set customer_type = 'ENTTCOMP' where id = 1009
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1017, 1, 'APTPISSA', NULL, 9999, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1018, 1, 'APTPISSA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1019, 1, 'APTPISSA', NULL, 9999, 0, 0, NULL, NULL, NULL, NULL, NULL)
/
update app_flow set is_contract_exist = null where id = 1001
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (1020, 1, 'APTPISSA', NULL, 9999, NULL, NULL, 'ENTTCOMP', NULL, NULL, NULL, NULL)
/
