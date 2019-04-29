------------ COM_DICTIONARY
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000013784, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10000337, 'Trace levels.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000001639, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10000338, 'Trace off')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000001240, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10000339, 'Fatal error')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000001640, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10000340, 'Error')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000001241, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10000341, 'Warning')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000001242, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10000342, 'Info')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000001641, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10000343, 'Debug')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136137, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004701, 'Debug info writing mode')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136139, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004702, 'Suspended recording')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136141, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004703, 'On error')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136143, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004704, 'Immediate saving')
/

------------ COM_LOV
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000001638, 'LANGENG', NULL, 'COM_LOV', 'NAME', 3, 'Trace levels')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136144, 'LANGENG', NULL, 'COM_LOV', 'NAME', 1030, 'Debug info writing mode')
/

------------ SET_PARAMETER
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000001221, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 1000, 'Trace level')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000002210, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 1001, 'Trace into dbms_output')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000001225, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 1002, 'Trace into log table')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000001226, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 1003, 'Trace into session')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000013785, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 1008, 'Tracing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136135, 'LANGEND', NULL, 'SET_PARAMETER', 'CAPTION', 1036, 'Debug info writing mode')
/

------------ ACM_PRIVILEGE
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000116618, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 1663, 'View trace log')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028748, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000023, 'Unloading logs')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028754, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1334, 'Unloading logs')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028750, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10001815, 'Entity type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028752, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10001816, 'Object')
/
delete com_i18n where id = 100000045636
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045636, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011473, 'Invalid request')
/
update com_i18n set text = 'Invalid input parameters.' where id = 100000045636
/
update com_i18n set text = 'Invalid input parameters' where id = 100000045636
/
update com_i18n set text = 'Trace logs unloading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000023 and lang = 'LANGENG'
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047404, 'LANGENG', NULL, 'COM_LOV', 'NAME', 486, 'Users')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047408, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10002798, 'User')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047410, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005894, 'Audit log file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047406, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000893, 'Unload audit log')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047412, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1391, 'Audit log')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049649, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10002829, 'Trace into file')
/
delete from com_i18n where id = 100000049649
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052174, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009654, 'The oracle tracing was enabled. File name [#1]. Transform the oracle trace file with command [#2].')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052175, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009656, 'The oracle tracing was disabled. File name [#1]. Transform the oracle trace file with command [#2].')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052178, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006972, 'Oracle trace level')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052179, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006973, 'No trace')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052180, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006974, 'Simple tracing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052181, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006975, 'Tracing with bind variables')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052182, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006976, 'Tracing with waits')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052183, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006977, 'Tracing with waits and bind variables')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052184, 'LANGENG', NULL, 'COM_LOV', 'NAME', 1054, 'Oracle trace levels')
/
update com_i18n set text='The oracle tracing was enabled. Level [#1]. File name [#2]. Transform the oracle trace file with command [#3].' where id=100000052174
/
update com_i18n set text='The oracle tracing was disabled. File name [#2]. Transform the oracle trace file with command [#3].' where id=100000052175
/
update com_i18n set text = 'Trace logs uploading' where id = 100000028748
/
update com_i18n set text = 'Upload audit log' where id = 100000047406
/
update com_i18n set text = 'Unloading logs' where id = 100000028748
/
update com_i18n set text = 'Unload audit log' where id = 100000047406
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007561, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003979, 'External log configuration file')
/
update com_i18n set lang = 'LANGENG' where id = 100000136135
/
