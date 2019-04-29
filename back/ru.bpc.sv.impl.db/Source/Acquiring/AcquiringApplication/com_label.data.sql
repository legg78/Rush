insert into com_label (id, name, label_type, module_code, env_variable) values (10003948, 'INVALID_TERMINAL_STATUS', 'ERROR', 'AAP', 'STATUS')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003947, 'INVALID_MERCHANT_STATUS', 'ERROR', 'AAP', 'STATUS')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003621, 'BANK_CUSTOMER_NOT_FOUND', 'ERROR', 'AAP', 'INST_ID, AGENT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003620, 'TOO_MANY_BANK_CUSTOMER', 'ERROR', 'AAP', 'INST_ID, AGENT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003619, 'TOO_MANY_BANK_MERCHANT', 'ERROR', 'AAP', 'INST_ID, AGENT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003618, 'BANK_MERCHANT_NOT_FOUND', 'ERROR', 'AAP', 'INST_ID, AGENT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009204, 'BUSINESS_ADDRESS_NOT_DEFINED', 'ERROR', 'APP', 'TERMINAL_NUMBER, MERCHANT_NUMBER')
/
insert into com_label (id, name, label_type, module_code) values (10009177, 'DISPENSER_NUMBER_IS_NOT_UNIQUE', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10009180, 'BAD_HOPPER_COUNT', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10009179, 'BAD_CASSETTE_COUNT', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10001876, 'INCORRECT_ENTITY_TO_ATTACH_ACCOUNT', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10000088, 'MCC_NOT_FOUND', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10000095, 'MERCHANT_ALREADY_EXIST', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10000096, 'MERCHANT_NOT_FOUND', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10000086, 'MERCHANT_NUMBER_IS_NOT_UNIQUE', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10000087, 'MERCHANT_TYPE_NOT_CORRESPOND_PARENT', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10001880, 'PLASTIC_NUMBER_NOT_UNIQUE', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10000102, 'TERMINAL_ALREADY_EXIST', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10000098, 'TERMINAL_ID_NOT_UNIQUE', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10000097, 'TERMINAL_NUMBER_NOT_UNIQUE', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10000100, 'TERMINAL_QUANTITY_LESS_THAN_1', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10002677, 'TEMPLATE_NOT_FOUND', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10003157, 'BAD_TERMINAL_NUMBER_COUNT', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code) values (10005967, 'CANNOT_CHANGE_CLOSED_MERCHANT', 'ERROR', 'AAP')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009886, 'SEC_QUESTION_NOT_DEFINED', 'ERROR', 'APP', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005184, 'CANNOT_CHANGE_CLOSED_TERMINAL', 'ERROR', 'AAP', 'TERMINAL_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011297, 'WRONG_CUSTOMER_TYPE', 'ERROR', 'APP', 'ENTITY_TYPE')
/
delete com_label where id = 10011297
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009451, 'ADDRESS_IS_MANDATORY_FOR_NEW_MERCHANT', 'ERROR', 'APP', NULL)
/
update com_label set env_variable = 'MERCHANT_ID, MERCHANT_NUMBER, INST_ID' where id = 10000096
/
delete from com_label where id in (10000098, 10000097)
/
