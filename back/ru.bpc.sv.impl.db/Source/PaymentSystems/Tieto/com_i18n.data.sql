insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137526, 'LANGENG', NULL, 'CMN_STANDARD', 'LABEL', 1038, 'TIETO Clearing (KONTS Format)')
/
delete com_i18n where id = 100000137527
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137527, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10003157, 'Center code')
/
delete com_i18n where id = 100000137528
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137528, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10003156, 'CMI')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137529, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001036, 'Tieto clearing file loading')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137530, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001037, 'Tieto clearing file unloading')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137531, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1484, 'Incoming clearing file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137532, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1485, 'Outgoing clearing file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137533, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007070, 'Tieto clearing file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137534, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1667, 'Create Tieto financial message')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137535, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10012042, 'Incoming file name [#1] doesn''t match file name from header [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137536, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10012043, 'Unable to find CENTER_CODE [#1] of standard [#2] of host [#3]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137537, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10012044, 'File records count [#1] not match data from file trailer [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137538, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10012045, 'File control amounts tran_sum [#1], control_sum [#1] not match data from file trailer [#3], [#4]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137539, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10012046, 'File header must be first line in file but found on line [#1]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137540, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10012047, 'Unknow/unsupported message type mtid [#1]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137541, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10012048, 'No trailed found in file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054560, 'LANGENG', NULL, 'RUL_MOD_SCALE', 'NAME', 1018, 'Tieto offline standard parametrization')
/
update com_i18n set text = 'Sender CMI' where id = 100000137528
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054561, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10003154, 'Settlement CMI')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054562, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10003155, 'Use authorization acquiring bin as Sender CMI')
/

