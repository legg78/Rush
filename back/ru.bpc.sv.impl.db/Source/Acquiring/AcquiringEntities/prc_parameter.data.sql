insert into prc_parameter (id, param_name, data_type, lov_id) values (10003974, 'I_FEE_TYPE', 'DTTPCHAR', 14)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003975, 'I_POSITIVE_ARRAY', 'DTTPNMBR', 167)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003976, 'I_NEGATIVE_ARRAY', 'DTTPNMBR', 167)
/
update prc_parameter set lov_id = 597 where id = 10003975
/
update prc_parameter set lov_id = 597 where id = 10003976
/
