insert into rul_mod_param (id, name, data_type, lov_id) values (10003352, 'OVERLIMIT_FEE_TYPE', 'DTTPCHAR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003699, 'DETAILED_ENTITIES_ARRAY_ID', 'DTTPNMBR', 167)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003742, 'LENDING_AMOUNT_NAME', 'DTTPCHAR', 1010)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003743, 'LENDING_BUNCH_TYPE', 'DTTPNMBR', 1022)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003787, 'STOP_AGING_EVENT', 'DTTPCHAR', 615)
/
delete rul_mod_param where id = 10003787
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003936, 'INVOICE_AGING_PERIOD', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10003962, 'IS_DAILY_MAD', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004053, 'IS_MAD_PAID', 'DTTPNMBR', 4)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004054, 'OVERDUE_DATE', 'DTTPDATE', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004067, 'MAD_VALUE', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004068, 'TAD_VALUE', 'DTTPNMBR', NULL)
/
delete rul_mod_param where id = 10003962
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004500, 'INVOICE_ID', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004501, 'OVERDRAFT_BALANCE', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004502, 'PAYMENT_AMOUNT', 'DTTPNMBR', NULL)
/
insert into rul_mod_param (id, name, data_type, lov_id) values (10004503, 'MAKE_TAD_EQUAL_MAD', 'DTTPNMBR', 4)
/
