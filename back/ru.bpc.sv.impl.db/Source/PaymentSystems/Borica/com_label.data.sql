insert into com_label (id, name, label_type, module_code, env_variable) values (10009384, 'BGN_USUPPORTED_FILE_TYPE', 'ERROR', 'BGN', 'FILE_TYPE')
/
update com_label set name = 'BGN_UNSUPPORTED_FILE_TYPE' where id = 10009384
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011157, 'BGN_WRONG_STRING_LENGTH', 'ERROR', 'BGN', 'RECORD_NUMBER, EXPECTED_LENGTH')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011158, 'BGN_WRONG_STRING_IDENTIFICATOR', 'ERROR', 'BGN', 'RECORD_NUMBER, EXPECTED_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011159, 'BGN_RECORDS_AFTER_FOOTER', 'ERROR', 'BGN', 'RECORD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011160, 'BGN_WRONG_FILE_LABEL', 'ERROR', 'BGN', 'RECORD_NUMBER, EXPECTED_LABEL')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011162, 'BGN_FILE_ALREADY_PROCESSED', 'ERROR', 'BGN', 'FILE_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011163, 'BGN_WRONG_RECORD_SEQ_NUMBER', 'ERROR', 'BGN', 'RECORD_NUMBER, EXPECTED_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011164, 'BGN_WRONG_TEST_OPTION', 'ERROR', 'BGN', 'RECORD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011165, 'BGN_WRONG_DEBIT_TOTAL', 'ERROR', 'BGN', 'RECORD_NUMBER, EXPECTED_DEBIT_TOTAL, DEBIT_TOTAL')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011166, 'BGN_WRONG_CREDIT_TOTAL', 'ERROR', 'BGN', 'RECORD_NUMBER, EXPECTED_CREDIT_TOTAL, CREDIT_TOTAL')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011167, 'BGN_WRONG_DEBIT_AMOUNT', 'ERROR', 'BGN', 'RECORD_NUMBER, EXPECTED_DEBIT_AMOUNT, DEBIT_AMOUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011168, 'BGN_WRONG_CREDIT_AMOUNT', 'ERROR', 'BGN', 'RECORD_NUMBER, EXPECTED_CREDIT_AMOUNT, CREDIT_AMOUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011169, 'BGN_WRONG_TRANSACTION_TYPE', 'ERROR', 'BGN', 'RECORD_NUMBER, TRANS_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011170, 'BGN_WRONG_TITLE_CODE', 'ERROR', 'BGN', 'RECORD_NUMBER, TITLE_CODE, EXPECTED_TITLE_CODE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011171, 'BGN_WRONG_APP_CODE', 'ERROR', 'BGN', 'RECORD_NUMBER, APP_CODE, EXPECTED_APP_CODE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011172, 'BGN_WRONG_MESSAGE_CODE', 'ERROR', 'BGN', 'RECORD_NUMBER, APP_CODE, EXPECTED_APP_CODE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011173, 'BGN_WRONG_NUMBER_OF_PACKAGES', 'ERROR', 'BGN', 'RECORD_NUMBER, PKG_TOTAL, EXPECTED_PKG_TOTAL')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011174, 'BGN_WRONG_CONTROL_AMOUNT', 'ERROR', 'BGN', 'RECORD_NUMBER, CONTROL_AMOUNT, EXPECTED_AMOUNT')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011175, 'BGN_WRONG_PACKAGE_SEQ_NUMBER', 'ERROR', 'BGN', 'RECORD_NUMBER, SEQ_NUMBER, EXPECTED_SEQ_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011176, 'BGN_WRONG_PACKAGE_TYPE', 'ERROR', 'BGN', 'RECORD_NUMBER, PACKAGE_TYPE, EXPECTED_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011177, 'BGN_WRONG_MESSAGE_TYPE', 'ERROR', 'BGN', 'RECORD_NUMBER, MESSAGE_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011178, 'BGN_WRONG_OPERATION_TYPE', 'ERROR', 'BGN', 'RECORD_NUMBER, OPERATION_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011179, 'BGN_WRONG_BALANCE_INDICATOR', 'ERROR', 'BGN', 'RECORD_NUMBER, INDICATOR')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011180, 'BGN_WRONG_TERMINAL_TYPE', 'ERROR', 'BGN', 'RECORD_NUMBER, TERMINAL_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011181, 'BGN_WRONG_CARD_TYPE', 'ERROR', 'BGN', 'RECORD_NUMBER, CARD_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011186, 'BGN_FILE_RECORD_NOT_FOUNT', 'ERROR', 'BGN', 'FILE_TYPE, FILE_NUMBER, DATE, TEST, SENDER, RECEIVER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011187, 'BGN_FIN_RECORD_NOT_FOUNT', 'ERROR', 'BGN', 'TRANS_NUMBER, FILE_ID, DATE, TEST, SENDER, RECEIVER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011242, 'BGN_ORIGINAL_TRANSACTION_NOT_FOUND', 'ERROR', 'BGN', 'TRANS_NUMBER')
/
delete from com_label where id in (10011169, 10011164, 10011181, 10011179)
/
delete from com_label where id in (10011178, 10011180)
/
delete from com_label where id = 10011177
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011181, 'BGN_WRONG_CARD_TYPE', 'ERROR', 'BGN', 'RECORD_NUMBER, CARD_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011178, 'BGN_WRONG_OPERATION_TYPE', 'ERROR', 'BGN', 'RECORD_NUMBER, OPERATION_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011179, 'BGN_WRONG_BALANCE_INDICATOR', 'ERROR', 'BGN', 'RECORD_NUMBER, INDICATOR')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011177, 'BGN_WRONG_MESSAGE_TYPE', 'ERROR', 'BGN', 'RECORD_NUMBER, MESSAGE_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009404, 'BGN_INCONSISTENT_MERCHANTS', 'ERROR', 'BGN', 'ACQ_PART_MERCHANT_ID, ACQ_PART_TERMINAL_ID, MERCHANT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009405, 'BGN_SETTLMENT_TYPE_NOT_DEFINED', 'ERROR', 'BGN', 'OPERATION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011169, 'BGN_WRONG_TRANSACTION_TYPE', 'ERROR', 'BGN', 'RECORD_NUMBER, TRANS_TYPE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011164, 'BGN_WRONG_TEST_OPTION', 'ERROR', 'BGN', 'RECORD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009406, 'BGN_SESSION_FILE_INCOMING_NO_NOT_FOUND', 'ERROR', 'BGN', 'FILE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006913, 'BGN_WRONG_EXPIR_DATE', 'ERROR', 'BGN', 'CARD_MASK, EXPIR_DATE, ROW_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10006926, 'BGN_IMPORT_FAILED', 'ERROR', 'BGN', 'SESSION_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005801, 'BGN_BIN_NOT_FOUND', 'ERROR', 'BGN', 'BIN, BIN_MASK')
/
 