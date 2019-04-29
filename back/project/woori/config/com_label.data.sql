insert into com_label (id, name, label_type, module_code, env_variable) values (-50000010, 'CST_WOO_ERROR_ON_INSERTING_EVENT_OBJECT', 'ERROR', 'CST', 'EVENT_OBJECT_ID, OPER_ID, INST_ID, SPLIT_HASH')
/
update com_label set env_variable = 'ERROR_MESSAGE, EVENT_OBJECT_ID, OPER_ID, INST_ID, SPLIT_HASH' where id = -50000010
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000019, 'CST_WOO_INVALID_PROCESS_PARAMETER_VALUE', 'ERROR', 'CST', 'PARAMETER_NAME, PARAMETER_VALUE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (-50000030, 'RECORD_COUNT_NOT_MATCHES_WITH_HEADER', 'ERROR', NULL, NULL)
/
