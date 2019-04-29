insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001077, 1005, 'ACQ_BIN', 'ENTTNIFC', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001086, 1005, 'ACQ_ISS_IND', 'ENTTCMDV', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001087, 1005, 'ADDR_DATA_IND', 'ENTTCMDV', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001078, 1005, 'FORW_INST_ID', 'ENTTNIFC', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001080, 1005, 'FORW_INST_ID_800', 'ENTTCMDV', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001088, 1005, 'MC_CUSTOMER_ID', 'ENTTCMDV', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001295, 1005, 'PIN_KEY_INDEX', 'ENTTCMDV', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001358, 1005, 'MC_DIM_MODE', 'ENTTCMDV', 'DTTPCHAR', 326, 'MCMMSTOP', NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001387, 1016, 'EXPANSION', 'ENTTNIFC', 'DTTPNMBR', 4, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001438, 1016, 'RECONCILIATION_MODE', 'ENTTNIFC', 'DTTPCHAR', 338, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001439, 1016, 'START_FILE_NUMBER', 'ENTTNIFC', 'DTTPNMBR', NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001440, 1016, 'CLEARING_MODE', 'ENTTNIFC', 'DTTPCHAR', 337, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001441, 1016, 'CMID', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL)
/
delete from cmn_parameter where id = 10001387
/
update cmn_parameter set name = 'BUSINESS_ICA' where id = 10001441
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001728, 1016, 'ACQUIRER_BIN', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001808, 1016, 'FORW_INST_ID', 'ENTTNIFC', 'DTTPCHAR', null, null, null)
/
update cmn_parameter set default_value='1' where id=10001295
/

insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002358, 1016, 'COLLECTION_ONLY', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002366, 1016, 'CERTIFIED_EMV_COMPLIANT', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002718, 1005, 'NET_SESS_ACTIV_ON_OPEN_CONN', 'ENTTCMDV', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002808, 1005, 'H2H', 'ENTTCMDV', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002878, 1005, 'ECHO_TEST_PERIOD', 'ENTTCMDV', 'DTTPNMBR', NULL, '000000000000000000.0000', NULL, NULL, NULL)
/
update cmn_parameter set default_value='000000000000000001.0000' where id=10002718
/
update cmn_parameter set default_value='000000000000000900.0000' where id=10002878
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002885, 1005, 'NET_PROBE_PERIOD_SEC', 'ENTTCMDV', 'DTTPNMBR', NULL, '000000000000000030.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003778, 1016, 'TRIM_LEAD_ZEROS', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004463, 1016, 'BUSINESS_ICA_MAESTRO', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004545, 1016, 'MASTERCOM_ENABLED', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
