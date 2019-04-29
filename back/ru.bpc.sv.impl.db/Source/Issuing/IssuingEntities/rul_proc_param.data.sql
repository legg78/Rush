insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000197, 1148, 'FEE_TYPE', 14, 10, 0, 10000306)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000256, 1187, 'CYCLE_TYPE', 1021, 10, 0, 10000982)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000763, 1148, 'OPER_TYPE', 49, 20, 0, 10000302)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000764, 1148, 'MSG_TYPE', 1013, 30, 0, 10000662)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000765, 1148, 'OPERATION_STATUS', NULL, 40, 0, 10001010)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000766, 1148, 'STTL_TYPE', 1020, 50, 0, 10000305)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000767, 1148, 'CALCULATE_FEE', 4, 60, 0, 10001965)
/
update rul_proc_param set lov_id = 181 where id = 10000197
/
delete rul_proc_param where id = 10000973
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000973, 1572, 'PARTY_TYPE', 98, 10, 1, 10000977)
/
delete rul_proc_param where id = 10000974
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000974, 1572, 'ACCOUNT_NAME', 1011, 20, 0, 10000975)
/
delete rul_proc_param where id = 10000975
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000975, 1572, 'LIMIT_TYPE', 1004, 30, 0, 10000980)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000979, 1574, 'AMOUNT_NAME', 1010, 10, 1, 10000976)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000980, 1574, 'NEED_LOCK', 4, 20, 0, 10001723)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10000981, 1574, 'EFFECTIVE_DATE', 1012, 30, 0, 10000999)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001070, 1658, 'CARD_DELIVERY_STATUS', 539, 10, 1, 10003353)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001221, 1572, 'CARD_STATUS', 1003, 40, 0, 10000992)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001260, 1750, 'ENTITY_OBJECT_TYPE', 680, 10, 1, 10003739)
/
insert into rul_proc_param (id, proc_id, param_name, lov_id, display_order, is_mandatory, param_id) values (10001261, 1750, 'ENTITY_TYPE_DEPENDENT', 680, 20, 1, 10004270)
/
