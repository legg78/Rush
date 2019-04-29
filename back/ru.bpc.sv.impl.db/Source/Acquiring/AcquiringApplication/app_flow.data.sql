insert into app_flow (id, seqnum, appl_type, inst_id, template_appl_id) values (1, 1, 'APTPACQA', 9999, NULL)
/
insert into app_flow (id, seqnum, appl_type, inst_id, template_appl_id) values (6, 1, 'APTPACQA', 9999, 1)
/
insert into app_flow (id, seqnum, appl_type, inst_id, template_appl_id) values (7, 1, 'APTPACQA', 9999, NULL)
/
insert into app_flow (id, seqnum, appl_type, inst_id, template_appl_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id) values (10, 1, 'APTPACQA', 9999, NULL, NULL, NULL, 'ENTTCOMP', NULL, NULL)
/
delete from app_flow where id = 10
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (2017, 2, 'APTPACQA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
update app_flow set id = 2010 where id = 6
/
update app_flow set id = 2011 where id = 7
/
update app_flow set id = 2012 where id = 2017
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (2013, 1, 'APTPACQA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (2014, 1, 'APTPACQA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (2015, 1, 'APTPACQA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (2016, 1, 'APTPACQA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
insert into app_flow (id, seqnum, appl_type, template_appl_id, inst_id, is_customer_exist, is_contract_exist, customer_type, contract_type, mod_id, xslt_source, xsd_source) values (2018, 1, 'APTPACQA', NULL, 9999, 1, 1, NULL, NULL, NULL, NULL, NULL)
/
update app_flow set is_contract_exist = 1 where id = 2010
/
