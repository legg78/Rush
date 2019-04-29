insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137122, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006312, 'Priority Pass Lounge Visit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137134, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000908, 'Priority Pass visit lounge file loading')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137135, 'LANGENG', NULL, 'PRC_PROCESS', 'DESCRIPTION', 10000908, 'Process loads incoming CSV file with Priority Pass visit lounge data. Comma is used as values'' separator. Date (Visit field) should be in format yyyy-mm-dd.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137136, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1401, 'Priority Pass visit lounge file')
/
update com_i18n set text = 'Process downloads incoming CSV file with Priority Pass visit lounge data. Comma is used as values'' separator. Date (Visit field) should be in format yyyy-mm-dd.' where id = 100000137135
/
update com_i18n set text = 'Priority Pass visit lounge file downloading' where id = 100000137134
/
update com_i18n set text = 'Process loads incoming CSV file with Priority Pass visit lounge data. Comma is used as values'' separator. Date (Visit field) should be in format yyyy-mm-dd.' where id = 100000137135
/
update com_i18n set text = 'Priority Pass visit lounge file' where id = 100000137134
/
