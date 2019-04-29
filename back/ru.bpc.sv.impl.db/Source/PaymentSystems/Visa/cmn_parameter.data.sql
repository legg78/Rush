insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001081, 1004, 'ACQ_BIN', 'ENTTNIFC', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001082, 1004, 'ACQ_INST_COUNTRY', 'ENTTNIFC', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001083, 1004, 'FORW_INST_ID', 'ENTTNIFC', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001084, 1004, 'STATION_ID', 'ENTTCMDV', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001085, 1004, 'VIP_TEXT_FORMAT', 'ENTTCMDV', 'DTTPCHAR', null, null, null)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001111, 1008, 'VISA_BASEII_DIALECT', 'ENTTNIFC', 'DTTPCHAR', 270, 'VIB2VISA', NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001142, 1008, 'VISA_RETAIL_CPS_PARTICIPATION_FLAG', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001143, 1008, 'VISA_ATM_CPS_PARTICIPATION_FLAG', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001144, 1008, 'VISA_ACQ_BUSINESS_ID', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10001145, 1008, 'VISA_SECURITY_CODE', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into cmn_parameter  (id, standard_id, name, entity_type, data_type) values (10001195, 1011, 'ACQ_BIN', 'ENTTNIFC', 'DTTPCHAR')
/
insert into cmn_parameter  (id, standard_id, name, entity_type, data_type) values (10001196, 1011, 'ACQ_INST_COUNTRY', 'ENTTNIFC', 'DTTPCHAR')
/
insert into cmn_parameter  (id, standard_id, name, entity_type, data_type) values (10001197, 1011, 'FORW_INST_ID', 'ENTTNIFC', 'DTTPCHAR')
/
insert into cmn_parameter  (id, standard_id, name, entity_type, data_type) values (10001198, 1011, 'STATION_ID', 'ENTTCMDV', 'DTTPCHAR')
/
insert into cmn_parameter  (id, standard_id, name, entity_type, data_type) values (10001199, 1011, 'VIP_TEXT_FORMAT', 'ENTTCMDV', 'DTTPCHAR')
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001447, 1004, 'ACQUIRER_PASSWORD', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001448, 1004, 'DIRECTORY_URL', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001449, 1004, 'DIRECTORY_SECONDARY_URL', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id) values (10001535, 1004, 'IS_CPS', 'ENTTCMDV', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL)
/

insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002359, 1008, 'COLLECTION_ONLY', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
update cmn_parameter set name = 'VISA_ACQ_PROC_BIN' where id = 10001144
/
update cmn_parameter set name = 'VISA_ACQ_BUSINESS_ID' where id = 10001081
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value) values (10002710, 1008, 'VISA_ACQ_BUSINESS_ID', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL)
/
update cmn_parameter set data_type = 'DTTPCHAR', lov_id = 470, default_value = 'VCOCNOCO' where id = 10002359
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002858, 1008, 'VISA_PARENT_NETWORK', 'ENTTNIFC', 'DTTPNMBR', 1019, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002871, 1008, 'EURO_SETTLEMENT', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002872, 1004, 'NET_SESS_ACTIV_ON_OPEN_CONN', 'ENTTCMDV', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002879, 1004, 'ECHO_TEST_PERIOD', 'ENTTCMDV', 'DTTPNMBR', NULL, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10002880, 1011, 'ECHO_TEST_PERIOD', 'ENTTCMDV', 'DTTPNMBR', NULL, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003312, 1008, 'VCR_DISPUTE_ENABLE', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004121, 1008, 'RUB_SETTLEMENT', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004267, 1008, 'VISA_ACQ_PROC_BIN_HEADER', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
