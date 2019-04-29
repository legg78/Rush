insert into rul_mod_param (id, name, data_type, lov_id) values (10003410, 'INSTALMENT_COUNT', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003411, 'INSTALMENT_FIXED_AMOUNT', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003664, 'ALLOW_DPP_ACCELERATION', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003728, 'DPP_ACCELERATION_TYPE', 'DTTPCHAR', 196)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003935, 'INSTALMENT_NUMBER', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004250, 'CREATE_OPERATION', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004425, 'INSTALMENT_AMOUNT', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004426, 'ORIGINAL_OPERATION_ID', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004427, 'DPP_ALGORIGHM', 'DTTPCHAR', 1027)
/
update rul_mod_param set name = 'DPP_ALGORITHM' where id = 10004427
/
