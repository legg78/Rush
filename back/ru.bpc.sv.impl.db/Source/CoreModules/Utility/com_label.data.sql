insert into com_label (id, name, label_type, module_code) values (10003288, 'TABLE_RECORD_NOT_FOUND', 'ERROR', 'UTL')
/
insert into com_label (id, name, label_type, module_code) values (10003289, 'TABLE_IS_BLOCKED', 'ERROR', 'UTL')
/
insert into com_label (id, name, label_type, module_code) values (10003290, 'ERROR_UPDATE_TABLE', 'ERROR', 'UTL')
/
insert into com_label (id, name, label_type, module_code) values (10003291, 'UNSUPPORTED_FILENAME', 'ERROR', 'UTL')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10003810, 'UNABLE_TO_PARSE_STATEMENT', 'ERROR', 'UTL', 'SOURCE_TEXT, ERROR_MESSAGE')
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10004871, 'UNABLE_LOAD_CLOB_WITHOUT_ID', 'ERROR', 'UTL', 'TABLE_NAME')
/
delete com_label where id = 10004871
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10007365, 'INVALID_INSTANCE_TYPE_FOR_SYNC_SEQUENCES', 'ERROR', 'UTL', 'INSTANCE_TYPE')
/
