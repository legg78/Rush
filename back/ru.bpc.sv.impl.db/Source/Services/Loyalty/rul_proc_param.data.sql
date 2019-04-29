insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000323, 1270, 'AMOUNT_NAME', 1010, 20, 0, 10000976)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000325, 1270, 'PARTY_TYPE', 98, 40, 0, 10000977)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000322, 1270, 'ENTITY_TYPE', 1017, 10, 0, 10000325)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000324, 1270, 'ACCOUNT_NAME', 1011, 30, 0, 10000975)
/
delete rul_proc_param where id = 10000381
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000381, 1309, 'I_INST_ID', 1, 10, 1, 10001014)
/
delete rul_proc_param where id = 10000382
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000382, 1309, 'I_SERVICE_ID', 182, 20, 1, 10001013)
/
delete from rul_proc_param where id = 10000322
/
delete from rul_proc_param where id = 10000323
/
delete from rul_proc_param where id = 10000324
/
delete from rul_proc_param where id = 10000325
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001076, 1661, 'AMOUNT_NAME', 1010, 10, 0, 10000976)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001077, 1661, 'ACCOUNT_NAME', 1011, 20, 0, 10000975)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001078, 1661, 'PARTY_TYPE', 98, 30, 0, 10000977)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001079, 1661, 'ENTITY_TYPE', 1017, 40, 0, 10000325)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001080, 1661, 'RATE_TYPE', 1007, 50, 0, 10000978)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001130, 1674, 'BALANCE_TYPE', 1015, 10, 1, 10000304)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001131, 1674, 'RESULT_AMOUNT_NAME', 1010, 20, 1, 10000979)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001132, 1674, 'RESULT_ACCOUNT_NAME', 1011, 30, 1, 10001002)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001133, 1675, 'FEE_TYPE', 1010, 10, 1, 10000306)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001134, 1675, 'RESULT_AMOUNT_NAME', 1010, 20, 1, 10000979)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001135, 1675, 'RESULT_ACCOUNT_NAME', 1011, 30, 1, 10001002)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001139, 1676, 'AMOUNT_NAME', 1010, 10, 1, 10000976)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001140, 1676, 'SOURCE_ACCOUNT_NAME', 1011, 20, 1, 10001025)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001141, 1676, 'DESTINATION_ACCOUNT_NAME', 1011, 30, 1, 10001026)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001142, 1676, 'DEBIT_MACROS_TYPE', 1005, 40, 1, 10003413)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001143, 1676, 'CREDIT_MACROS_TYPE', 1005, 50, 1, 10003414)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001144, 1676, 'CONVERSION_TYPE', 274, 60, 0, 10001120)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001145, 1676, 'RATE_TYPE', 1007, 70, 0, 10000978)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001153, 1694, 'RESULT_AMOUNT_NAME', 1010, 10, 1, 10000979)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001154, 1694, 'CHECK_DIRECTION', 4, 20, 0, 10001311)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001233, 1249, 'PRODUCT_ATTRIBUTE', 1070, 130, 0, 10002379)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001234, 1251, 'PRODUCT_ATTRIBUTE', 1070, 110, 0, 10002379)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001235, 1252, 'PRODUCT_ATTRIBUTE', 1070, 90, 0, 10002379)
/
update rul_proc_param set lov_id = 667 where id = 10001233
/
update rul_proc_param set lov_id = 667 where id = 10001234
/
update rul_proc_param set lov_id = 667 where id = 10001235
/
