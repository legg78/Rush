delete com_label where id = 10011473
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10011473, 'INVALID_REQUEST', 'ERROR', 'TRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009654, 'ORACLE_TRACING_WAS_ENABLED', 'INFO', 'TRC', NULL)
/
insert into com_label (id, name, label_type, module_code, env_variable) values (10009656, 'ORACLE_TRACING_WAS_DISABLED', 'INFO', 'TRC', NULL)
/
update com_label set env_variable='TRACE_LEVEL, TRACE_FILE, TRANSFORM_COMMAND' where id=10009654
/
update com_label set env_variable='TRACE_FILE, TRANSFORM_COMMAND' where id=10009656
/
