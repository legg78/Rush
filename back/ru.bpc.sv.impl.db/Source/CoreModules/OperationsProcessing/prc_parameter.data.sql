insert into prc_parameter (id, param_name, data_type, lov_id) values (10002023, 'I_OPER_STATUS', 'DTTPCHAR', 106)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002277, 'I_APPROVEMENT', 'DTTPCHAR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002393, 'I_UPL_OPER_EVENT_TYPE', 'DTTPCHAR', 454)
/
delete prc_parameter where id = 10002394
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002394, 'I_LOAD_EVENTS_WITH_STATUS', 'DTTPCHAR', 457)
/
update prc_parameter set param_name = 'I_LOAD_STATE' where id = 10002394
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002715, 'I_LOAD_SUCCESSFULL', 'DTTPCHAR', 466)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002716, 'I_INCLUDE_AUTH', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002717, 'I_INCLUDE_CLEARING', 'DTTPNMBR', 4)
/
update prc_parameter set param_name = 'I_LOAD_MERGED' where id = 10002392
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002941, 'I_SPLIT_FILES', 'DTTPNMBR', 4)
/
update prc_parameter set param_name = 'I_LOAD_REVERSED' where id = 10002392
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002989, 'I_LOAD_MERGED', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003019, 'I_OPER_FILTER', 'DTTPCHAR', 1048)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003033, 'I_SPLITTED_FILES', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003047, 'I_REVERSAL_UPLOAD_TYPE', 'DTTPCHAR', 1057)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003519, 'I_DEPTH_PRESENTMENT', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003520, 'I_DEPTH_AUTHORIZATION', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003985, 'I_ARRAY_OPER_PARTICIPANT_TYPE', 'DTTPNMBR', 641)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003989, 'I_OPER_CURRENCY', 'DTTPCHAR', 25)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003990, 'I_ARRAY_OPER_STATUSES_ID', 'DTTPNMBR', 643)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004265, 'I_ARRAY_ACC_TYPE_ID', 'DTTPNMBR', 672, NULL)
/
update prc_parameter set param_name = 'I_ARRAY_ACCOUNT_TYPE_ID' where id = 10004265
/
delete from prc_parameter where id = 10004265
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004450, 'I_PARTICIPANT_TYPE', 'DTTPCHAR', 98, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004517, 'I_IS_EOD', 'DTTPNMBR', 4, NULL)
/
