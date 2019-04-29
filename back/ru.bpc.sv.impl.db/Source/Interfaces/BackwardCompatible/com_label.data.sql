insert into com_label (id, name, label_type, module_code, env_variable) values (10011474, 'R_IBI_FILE_RAW_LENGTH_INCORRECT', 'ERROR', 'ITF', 'LENGTH, RECORD_NUMBER')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011492, 'R_IBI_FILE_REJECT_REASON_INCORRECT', 'ERROR', 'ITF', NULL)
/
delete com_label where id = 10011495
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011495, 'OCP_FILE_RAW_LENGTH_INCORRECT', 'ERROR', 'ITF', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011522, 'IBI_FILE_RAW_LENGTH_INCORRECT', 'ERROR', 'ITF', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007011, 'CARDHOLDER_NAME_IS_TOO_LONG', 'ERROR', 'ITF', 'CARDHOLDER_NAME')
/
update com_label set env_variable = 'CARDHOLDER_NAME, LENGTH, MAX_LENGTH' where id = 10007011
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009584, 'CARDHOLDER_NAME_IS_TOO_SHORT', 'ERROR', 'ITF', 'CARDHOLDER_NAME, LENGTH, MIN_LENGTH')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009585, 'CARDHOLDER_NAME_STARTED_WITH_SPACE', 'ERROR', 'ITF', 'CARDHOLDER_NAME')
/
