insert into com_label (id, name, label_type, module_code) values (10001986, 'UNKNOWN_BIN_CARD_NUMBER_NETWORK', 'ERROR', 'VIS')
/
insert into com_label (id, name, label_type, module_code) values (10001995, 'VISA_FILE_ALREADY_PROCESSED', 'ERROR', 'VIS')
/
insert into com_label (id, name, label_type, module_code) values (10002004, 'VISA_BIN_NOT_REGISTERED', 'ERROR', 'VIS')
/
insert into com_label (id, name, label_type, module_code) values (10002111, 'VISA_FILE_WRONG_FORMAT', 'ERROR', 'VIS')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009941, 'UNKNOWN_NETWORK', 'ERROR', 'VIS', 'NETWORK_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009943, 'VIS_UNKNOWN_REPORT_GROUP', 'ERROR', 'VIS', 'REPORT_GROUP, REPORT_SUBGROUP')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009944, 'VIS_TSR1_RECORD_NOT_PRESENT', 'ERROR', 'VIS', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009945, 'VISA_ORIGINAL_MESSAGE_NOT_FOUND', 'ERROR', 'VIS', 'ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009946, 'VISA_WRONG_INST_SECURITY_CODE', 'ERROR', 'VIS', 'INST_ID, FILE_SECURITY_CODE, SECURITY_CODE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009947, 'VISA_FILE_CORRUPTED_INCORRECT_TRAILER_BIN', 'ERROR', 'VIS', 'FILE_BIN, BIN')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009948, 'VISA_WRONG_TEST_OPTION_PARAMETER', 'ERROR', 'VIS', 'TEST_OPTION, FILE_TEST_OPTION')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009950, 'CAN_NOT_MARK_ORIGINAL_MESSAGE_AS_RETURNED', 'ERROR', 'VIS', 'ORIG_BATCH_ID, ORIG_FILE_ID, ITEM_SEQ_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009951, 'VISA_FILE_CORRUPTED_INCORRECT_TRAILER_DATE', 'ERROR', 'VIS', 'PROC_DATE, FILE_DATE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011367, 'REVERSAL_AMOUNT_GREATER_ORIGINAL_AMOUNT', 'ERROR', 'VIS', 'ORIGINAL_OPER_AMOUNT, OPER_AMOUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011472, 'VISA_ACQ_BUSINESS_ID_NOT_FOUND', 'ERROR', 'VIS', 'INST_ID, STANDARD_ID, HOST_ID')
/
delete com_label where id = 10009945
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009431, 'VISA_ACQ_PROC_BIN_NOT_DEFINED', 'ERROR', 'VIS', 'INST_ID, STANDARD_ID, HOST_ID')
/
update com_label set name = 'VIS_TCR1_RECORD_IS_NOT_PRESENT', env_variable = 'FILE_ID, RECORD_NUMBER' where id = 10009944
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006403, 'TOO_MANY_VISA_AUTH', 'ERROR', 'VIS', 'AUTH_OPER_TYPE, REFNUM, STTL_DATE, REQ_MSG_TYPE')
/
