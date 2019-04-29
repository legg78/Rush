insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001215, 1726, 'PAYMENT_PURPOSE', 232, 10, 1, 10001305)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001216, 1726, 'CYCLE_TYPE', NULL, 20, 1, 10000982)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001217, 1724, 'AMOUNT_NAME', NULL, 10, 1, 10000976)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001218, 1724, 'PAYMENT_PURPOSE', NULL, 20, 1, 10001305)
/
update rul_proc_param set is_mandatory = 0 where id = 10001218
/
update rul_proc_param set lov_id = 1010 where id = 10001217
/
update rul_proc_param set lov_id = 232 where id = 10001218
/
update rul_proc_param set lov_id = 1021 where id = 10001216
/
update rul_proc_param set is_mandatory = 1 where id = 10001218
/
