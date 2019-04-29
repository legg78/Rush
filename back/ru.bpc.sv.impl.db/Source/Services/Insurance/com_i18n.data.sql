--------- PRC_PROCESS
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000019021, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000840, 'Insurance premium processing')
/

--------- PRD_SERVICE_TYPE
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018421, 'LANGENG', NULL, 'PRD_SERVICE_TYPE', 'LABEL', 10000955, 'Insurance company settlement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018423, 'LANGENG', NULL, 'PRD_SERVICE_TYPE', 'LABEL', 10000956, 'Credit insurance')
/

--------- PRD_ATTRIBUTE
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018431, 'LANGENG', NULL, 'PRD_ATTRIBUTE', 'LABEL', 10000957, 'Insurance company')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018443, 'LANGENG', NULL, 'PRD_ATTRIBUTE', 'LABEL', 10000958, 'Insurance base')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018445, 'LANGENG', NULL, 'PRD_ATTRIBUTE', 'LABEL', 10000959, 'Insurance rate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018447, 'LANGENG', NULL, 'PRD_ATTRIBUTE', 'LABEL', 10000960, 'Insurance tax rate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018469, 'LANGENG', NULL, 'PRD_ATTRIBUTE', 'LABEL', 10000961, 'Insurance premium')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018472, 'LANGENG', NULL, 'PRD_ATTRIBUTE', 'LABEL', 10000962, 'Settlement period')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018473, 'LANGENG', NULL, 'PRD_ATTRIBUTE', 'LABEL', 10000963, 'Payment purpose')
/

--------- COM_LOV
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018425, 'LANGENG', NULL, 'COM_LOV', 'NAME', 229, 'Insurance companies')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018430, 'LANGENG', NULL, 'COM_LOV', 'NAME', 230, 'Insurance base amount')
/

--------- COM_DICTIONARY
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018417, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003014, 'Insurance company service activation ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018418, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003015, 'Insurance company service deactivation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018419, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003016, 'Credit insurance service activation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018420, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003017, 'Credit insurance service deactivation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018424, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003018, 'Insurance company')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018426, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003019, 'Insurance base amount')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018427, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003020, 'Total amount due')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018428, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003021, 'Credit limit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018429, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003022, 'Unused credit limit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018444, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003027, 'Insurance rate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018446, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003028, 'Insurance tax rate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018468, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003035, 'Insurance premium')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000018471, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003036, 'Settlement period')
/
update com_i18n set text = 'Insurance premiums processing' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000840 and lang = 'LANGENG'
/
