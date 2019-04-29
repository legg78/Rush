insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003139, 1037, 'NBC_BANK_CODE', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004002, 1037, 'IBFT_TRANSFER_OPTP', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL) -- [@skip patch]
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004003, 1037, 'IBFT_ATM_OPTP', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL) -- [@skip patch]
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004004, 1037, 'IBFT_ATM_PAYMENT_OPTP', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL) -- [@skip patch]
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004005, 1037, 'IBFT_P2P_OPTP', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL) -- [@skip patch]
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004006, 1037, 'IBFT_PARTY_TYPE_ALGO', 'ENTTNIFC', 'DTTPCHAR', 644, 'NBCADFLT', NULL, NULL, NULL) -- [@skip patch]
/
delete from cmn_parameter where id = 10004002
/
delete from cmn_parameter where id = 10004003
/
delete from cmn_parameter where id = 10004004
/
delete from cmn_parameter where id = 10004005
/
delete from cmn_parameter where id = 10004006
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004002, 1037, 'IBFT_TRANSFER_OPTP', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004003, 1037, 'IBFT_ATM_OPTP', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004004, 1037, 'IBFT_ATM_PAYMENT_OPTP', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004005, 1037, 'IBFT_P2P_OPTP', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004006, 1037, 'IBFT_PARTY_TYPE_ALGO', 'ENTTNIFC', 'DTTPCHAR', 644, 'NBCADFLT', NULL, NULL, NULL)
/
