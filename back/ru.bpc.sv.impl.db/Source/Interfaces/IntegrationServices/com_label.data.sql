-- Errors
insert into com_label (id, name, label_type, module_code, env_variable) values (10005777, 'START_DATE_IS_EMPTY', 'ERROR', 'ITF', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10005779, 'END_DATE_IS_EMPTY', 'ERROR', 'ITF', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011940, 'CARD_CONTRACT_DIFFERS_FROM_ACCOUNT_CONTRACT', 'ERROR', 'ITF', 'CUSTOMER_ID, CARD_ID, CARD_CONTRACT_ID, ACCOUNT_ID, ACCOUNT_CONTRACT_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011994, 'CUSTOMER_ID_AND_NUMBER_MISMATCH', 'ERROR', 'ITF', 'CUSTOMER_ID, CUSTOMER_NUMBER, INST_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011996, 'CARD_ID_AND_NUMBER_MISMATCH', 'ERROR', 'ITF', 'CARD_ID, CARD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011998, 'ACCOUNT_ID_AND_NUMBER_MISMATCH', 'ERROR', 'ITF', 'ACCOUNT_ID, ACCOUNT_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10012000, 'CARD_INSTANCE_DATA_ARE_INCONSISTENT', 'ERROR', 'ITF', 'CARD_ID, INSTANCE_ID, SEQ_NUMBER, EXPIR_DATE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10012004, 'CARD_OR_ACCOUNT_DOES_NOT_BELONG_TO_CUSTOMER', 'ERROR', 'ITF', 'CARD_ID, ACCOUNT_ID, CUSTOMER_ID')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10013460, 'CARDS_NOT_FOUND', 'ERROR', 'ITF', 'CARD_MASK, INST_ID')
/
