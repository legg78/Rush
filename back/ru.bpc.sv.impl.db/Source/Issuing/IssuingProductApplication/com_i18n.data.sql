delete from com_i18n where id = 100000056138
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056138, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007505, 'Product application')
/
delete from com_i18n where id = 100000056022
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056022, 'LANGENG', NULL, 'APP_FLOW', 'LABEL', 1701, 'Default product application')
/
update com_i18n set text = 'Issuing product application' where id = 100000056138
/
update com_i18n set text = 'Default issuing product application' where id = 100000056022
/
