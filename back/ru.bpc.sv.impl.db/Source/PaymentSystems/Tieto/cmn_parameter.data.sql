delete cmn_parameter where id = 10003122
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003157, 1038, 'CENTER_CODE', 'ENTTNIFC', 'DTTPNMBR', NULL, NULL, NULL, NULL, NULL)
/
delete cmn_parameter where id =  10003123
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003156, 1038, 'CMI', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, NULL, NULL)
/
update cmn_parameter set scale_id = 1018 where id = 10003122
/
update cmn_parameter set scale_id = 1018, name = 'SEND_CMI' where id = 10003156
/
delete cmn_parameter where id = 10003154
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003154, 1038, 'SETTL_CMI', 'ENTTNIFC', 'DTTPCHAR', NULL, NULL, NULL, 1018, NULL)
/
delete cmn_parameter where id = 10003155
/
insert into cmn_parameter (id, standard_id, name, entity_type, data_type, lov_id, default_value, xml_default_value, scale_id, pattern) values (10003155, 1038, 'USE_AUTH_ACQ_BIN_AS_SEND_CMI', 'ENTTNIFC', 'DTTPNMBR', 4, 0, NULL, 1018, NULL)
/
