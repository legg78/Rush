insert into com_label (id, name, label_type, module_code, env_variable) values (10009683, 'DCI_FIN_MESSAGE_NOT_FOUND', 'ERROR', 'DIN', 'FIN_MESSAGE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009685, 'DIN_ACQ_AGENT_CODE_IS_NOT_DEFINED', 'ERROR', 'DIN', 'INST_ID, STANDARD_ID, HOST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009687, 'DIN_ORIGINAL_FIN_MESSAGE_NOT_FOUND', 'ERROR', 'DIN', 'FIN_MESSAGE_ID, ORIGINAL_FIN_MESSAGE_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009689, 'DIN_BIN_RANGE_IS_NOT_UNIQUE', 'ERROR', 'DIN', 'CARD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009691, 'DIN_BIN_RANGE_IS_NOT_DEFINED', 'ERROR', 'DIN', 'CARD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009693, 'DIN_TYPE_OF_CHARGE_IS_NOT_DEFINED', 'ERROR', 'DIN', 'OPER_TYPE, IS_REVERSAL, TERMINAL_TYPE, MCC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009695, 'DIN_NO_IMPACT_FOR_TYPE_OF_CHARGE', 'ERROR', 'DIN', 'TYPE_OF_CHARGE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009697, 'DIN_POS_ARTICLE_IS_NOT_MAPPED', 'ERROR', 'DIN', 'POS_ARTICLE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009699, 'DIN_RATE_TYPE_IS_NOT_DEFINED', 'ERROR', 'DIN', 'CURR_CODE, INST_ID, STANDARD_ID, HOST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009701, 'DIN_ALT_CURRENCY_RATE_ERROR', 'ERROR', 'DIN', 'CURR_CODE, ALT_CURR_CODE, ALT_RATE_TYPE, INST_ID, RECAP_DATE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009703, 'DIN_INVALID_PROGRAM_TRANSACTION_AMOUNT', 'ERROR', 'DIN', 'INST_ID, STANDARD_ID, HOST_ID, PROGRAM_TRNSC_AMOUNT, MIN_VALUE, MAX_VALUE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009705, 'DIN_INVALID_ATMID', 'ERROR', 'DIN', 'TERMINAL_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009736, 'DIN_OPER_PARAMETERS_ARE_NOT_DEFINED', 'ERROR', 'DIN', 'TYPE_OF_CHARGE, MCC')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009738, 'DIN_UNKNOWN_FUNCTION_CODE', 'ERROR', 'DIN', 'FUNCTION_CODE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009740, 'DIN_UNKNOWN_AGENT_CODE', 'ERROR', 'DIN', 'AGENT_CODE, NETWORK_ID, STANDARD_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009751, 'DCI_ORIGINAL_FIN_MESSAGE_NOT_FOUND', 'ERROR', 'DIN', 'FIN_MESSAGE_ID, CARD_NUMBER, NETWORK_REFNUM')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009753, 'DIN_MANDATORY_FIELD_IS_MISSED', 'ERROR', 'DIN', 'MESSAGE_CATEGORY, FUNCTION_CODE, FIELD_POSITION, FIELD_NAME, FIELD_DESCRIPTION')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009755, 'DIN_INCORRECT_TRANSACTION_CODE', 'ERROR', 'DIN', 'FUNCTION_CODE, TRANSACTION_CODE, SOURCE_LINE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009757, 'DIN_INCORRECT_COUNT_OF_FIELDS', 'ERROR', 'DIN', 'MESSAGE_CATEGORY, FUNCTION_CODE, FIELD_POSITION, MAX_FIELD_POSITION')
/
update com_label set name = 'DIN_FIN_MESSAGE_NOT_FOUND' where id = 10009683
/
update com_label set name = 'DIN_ORIGINAL_FIN_MESSAGE_NOT_FOUND_BY_REFNUM' where id = 10009751
/
