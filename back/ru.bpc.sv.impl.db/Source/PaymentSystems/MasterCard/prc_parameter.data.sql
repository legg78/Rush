insert into prc_parameter (id, param_name, data_type, lov_id) values (10001380, 'I_TABLE', 'DTTPCHAR', 332)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001462, 'EXPANSION', 'DTTPNMBR', 4)
/
update prc_parameter set param_name = 'I_EXPANSION' where id = 10001462
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001708, 'I_RECORD_FORMAT', 'DTTPCHAR', 344)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001712, 'I_DEST_CURR', 'DTTPCHAR', 25)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001713, 'I_YEAR', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10001714, 'I_QUARTER', 'DTTPNMBR', NULL)
/

delete from prc_parameter where id in  (10001714, 10001713, 10001712)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002347, 'I_UPLOAD_INST', 'DTTPCHAR', 45)
/

insert into prc_parameter (id, param_name, data_type, lov_id) values (10002770, 'I_REPORT_NAME', 'DTTPCHAR', 477)
/
update prc_parameter set param_name='I_USE_INST' where id=10002347
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003777, 'I_CMID_NETWORK_ID', 'DTTPNMBR', 1019)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004392, 'I_CREATE_REV_REJECT', 'DTTPNMBR', 4, NULL)
/
delete from prc_parameter where id = 10002347
/
