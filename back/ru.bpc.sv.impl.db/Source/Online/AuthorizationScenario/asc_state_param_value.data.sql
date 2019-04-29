insert into asc_state_param_value (param_value, param_id, state_id) values ('000000000000000099.0000', 3, 1)
/
insert into asc_state_param_value (param_value, param_id, state_id) values ('000000000000000099.0000', 4, 1)
/
insert into asc_state_param_value (param_value, param_id, state_id) values ('000000000000000099.0000', 19, 1)
/
insert into asc_state_param_value (param_value, param_id, state_id) values ('000000000000000099.0000', 7, 1)
/
insert into asc_state_param_value (param_value, param_id, state_id) values ('000000000000000099.0000', 27, 1)
/
insert into asc_state_param_value (state_id, param_id, param_value) values (3, 3, '000000000000000099.0000')
/
update asc_state_param_value set param_value = '000000000000000098.0000' where state_id = 1 and param_id = 3
/