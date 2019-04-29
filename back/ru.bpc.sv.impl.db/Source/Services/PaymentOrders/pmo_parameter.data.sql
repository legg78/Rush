insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000013, 1, 'SOURCE_CLIENT_ID_TYPE', 'DTTPCHAR', 1016, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000014, 1, 'SOURCE_CLIENT_ID_VALUE', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000015, 1, 'CBS_TRANSFER_FIRST_NAME', 'DTTPCHAR', NULL, '^[[:alpha:]]{1,200}', NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000016, 1, 'CBS_TRANSFER_SECOND_NAME', 'DTTPCHAR', NULL, '^[[:alpha:]]{1,200}', NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000017, 1, 'CBS_TRANSFER_SURNAME', 'DTTPCHAR', NULL, '^[[:alpha:]]{1,200}', NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000024, 1, 'PARTNER_IDENTIFIER', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000025, 1, 'PARTNER_TRANSACTION_ID', 'DTTPCHAR', NULL, '^[[:alpha:]]{1,32}', NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000026, 1, 'CARD_NETWORK', 'DTTPNMBR', 1019, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000027, 1, 'CARDHOLDER_NAME', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000028, 1, 'CARD_MASK', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000029, 1, 'OPER_SURCHARGE_AMOUNT', 'DTTPNMBR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000030, 1, 'OPER_REASON', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000031, 3, 'CBS_TRANSFER_RECIPIENT_KPP', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000032, 1, 'PMT_PHONE', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000033, 1, 'PMT_MOBILE_PHONE', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000034, 1, 'PMT_ACCOUNT', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id) values (10000035, 1, 'PMT_CONTRACT', 'DTTPCHAR', NULL, NULL, NULL)
/
insert into prc_parameter (id, param_name, data_type, lov_id, parent_id) values (10004020, 'I_PMO_STATUS_CHANGE_MODE', 'DTTPCHAR', 645, NULL)
/
delete prc_parameter where id = 10004020
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id, param_function) values (10000036, 1, 'INVOICE_DUE_DATE', 'DTTPDATE', NULL, NULL, NULL, 'pmo_api_param_function_pkg.get_due_date')
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id, param_function) values (10000037, 1, 'INVOICE_MAD', 'DTTPNMBR', NULL, NULL, NULL, 'pmo_api_param_function_pkg.get_mad')
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id, param_function) values (10000040, 1, 'ACCOUNT_NUMBER', 'DTTPCHAR', NULL, NULL, NULL, 'pmo_api_param_function_pkg.get_account_number')
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id, param_function) values (10000041, 1, 'CARD_NUMBER', 'DTTPNMBR', NULL, NULL, NULL, 'pmo_api_param_function_pkg.get_card_number')
/
insert into pmo_parameter (id, seqnum, param_name, data_type, lov_id, pattern, tag_id, param_function) values (10000042, 1, 'PURPOSE_TEXT', 'DTTPCHAR', NULL, NULL, NULL, NULL)
/
