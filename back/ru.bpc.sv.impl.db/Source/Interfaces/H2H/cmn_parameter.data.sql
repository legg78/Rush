insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004209, 1052, 'FORW_INST_ID', 'ENTTNIFC', 'DTTPNMBR', NULL, NULL, NULL, NULL, NULL)
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004210, 1052, 'RECEIV_INST_ID', 'ENTTNIFC', 'DTTPNMBR', NULL, NULL, NULL, NULL, NULL)
/
delete from cmn_parameter where id = 10004209
/
delete from cmn_parameter where id = 10004210
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10004345, 1052, 'H2H_INST_CODE', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
