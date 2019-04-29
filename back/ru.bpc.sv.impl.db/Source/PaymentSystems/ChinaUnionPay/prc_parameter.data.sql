insert into prc_parameter (id, param_name, data_type, lov_id) values (10002874, 'I_ISSUER', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002875, 'I_CUP_LOAD_TYPE', 'DTTPCHAR', 7003)
/
update prc_parameter set lov_id = 1052 where id  = 10002875
/
