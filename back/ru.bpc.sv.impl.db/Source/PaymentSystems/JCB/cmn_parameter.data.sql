insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003052, 1032, 'ACQUIRER_BIN', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003053, 1032, 'BUSINESS_ICA', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003054, 1032, 'FORW_INST_ID', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
update cmn_parameter set name = 'RECV_INST_ID' where id = 10003054
/
delete from cmn_parameter where id = 10003052
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003938, 1032, 'ATM_FEE_CHARGE', 'ENTTNIFC', 'DTTPNMBR', NULL, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003969, 1071, 'BUSINESS_ICA', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003970, 1071, 'RECV_INST_ID', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003971, 1071, 'ATM_FEE_CHARGE', 'ENTTNIFC', 'DTTPNMBR', 4, '000000000000000000.0000', NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004300, 1032, 'MERCHANT_COMMISS_RATE', 'ENTTNIFC', 'DTTPCHAR', 14, NULL, NULL, NULL, NULL)
/
