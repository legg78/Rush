insert into prc_parameter (id, param_name, data_type, lov_id) values (10002017, 'I_RATE_TYPE', 'DTTPCHAR', 1007)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002115, 'I_TRANSACTION_TYPE', 'DTTPCHAR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002965, 'I_EMPTY_ADDRESS', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10002996, 'I_UNLOAD_ACCOUNTS', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003001, 'I_CHECK_CARDHOLDER_NAME', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003039, 'I_INCLUDE_SERVICE', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003086, 'I_CARD_COUNT', 'DTTPNMBR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003140, 'I_VERSION', 'DTTPCHAR', 517)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003143, 'I_INCLUDE_NOTE', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003650, 'I_INCLUDE_FLEXIBLE', 'DTTPNMBR', 4)
/
update prc_parameter set param_name = 'I_INCLUDE_FLEXIBLE_FIELDS' where id = 10003650
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003740, 'I_ACCOUNT_NUMBER_COLUMN', 'DTTPCHAR', NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003934, 'I_OCG_VERSION', 'DTTPCHAR', 630)
/
insert into prc_parameter (id, param_name, data_type, lov_id) values (10003983, 'I_UNLOAD_PAYMENTS', 'DTTPNMBR', 4)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004277, 'I_UNLOAD_ACQUIRING_ACCOUNTS', 'DTTPNMBR', 4, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004302, 'I_FLOW_ID', 'DTTPNMBR', 686, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004407, 'I_INCLUDE_VISA_CLEARING', 'DTTPNMBR', 4, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004408, 'I_INCLUDE_MASTERCARD_CLEARING', 'DTTPNMBR', 4, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004409, 'I_INCLUDE_PAYMENT_ORDER', 'DTTPNMBR', 4, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004410, 'I_INCLUDE_ADDITIONAL_AMOUNT', 'DTTPNMBR', 4, NULL)
/
