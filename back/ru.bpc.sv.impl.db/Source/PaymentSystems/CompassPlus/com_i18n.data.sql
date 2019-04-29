insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136524, 'LANGENG', NULL, 'CMN_STANDARD', 'LABEL', 1026, 'Compass Plus clearing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136635, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10002291, 'Compass Plus aquirer name')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136636, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000868, 'Compass Plus incoming clearing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136637, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000869, 'Compass Plus outgoing clearing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136638, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1367, 'CMP incoming file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136639, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1368, 'CMP outgoing clearing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045611, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011459, 'Presentment cannot be after trailer.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045615, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011461, 'Compass Plus institution not found.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045617, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011462, 'Trailer was not found.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045660, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011494, 'HEADER_NOT_FOUND')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045669, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011503, 'CMP_WRONG_TEST_OPTION_PARAMETER')
/
update com_i18n set text = 'Header of file is not found.' where id = 100000045660
/
update com_i18n set text = 'Wrong test mode. [#1]!=[#2]' where id = 100000045669
/
update com_i18n set text = 'Compass Plus clearing file loading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000868 and lang = 'LANGENG'
/
update com_i18n set text = 'Compass Plus clearing file unloading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000869 and lang = 'LANGENG'
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052161, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006969, 'Clearing Compass file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052254, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006986, 'Uploading of collection only')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052255, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006987, 'Upload all')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052256, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006988, 'Upload collection only')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052257, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006989, 'Upload not collection only')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052262, 'LANGENG', NULL, 'COM_LOV', 'NAME', 1058, 'Collection only upload types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052263, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003048, 'Collection only upload type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052269, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10003049, 'Compass Plus name of destination institution')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052277, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006990, 'Ready for upload collection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052345, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10003058, 'Acquirer BIN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052563, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009747, 'Unable to determine sttl_type for operation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052565, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009748, 'Unable to determine type of operation')
/
update com_i18n set text = 'Unable to determine type of operation by the following parameters: transaction type [#1], card number [#2], issuing institution [#3], acquiring institution [#4], card institution [#5], issuing/acquiring network [#6]' where id = 100000052565
/
update com_i18n set text = 'Unable to determine "Settlement type" for operation by the following parameters: transaction type [#1], card number [#2], issuing institution [#3], acquiring institution [#4], card institution [#5], issuing/acquiring network [#6]' where id = 100000052563
/
update com_i18n set text = 'Unable to determine type of operation by trans_code [#1]' where id = 100000052565
/
update com_i18n set text = 'Compass Plus clearing file uploading' where id = 100000136637
/
update com_i18n set text = 'Compass Plus clearing file downloading' where id = 100000136636
/
update com_i18n set text = 'Compass Plus outgoing clearing' where id = 100000136637
/
update com_i18n set text = 'Compass Plus incoming clearing' where id = 100000136636
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000065427, 'LANGENG', NULL, 'CMN_STANDARD_VERSION', 'DESCRIPTION', 1056, 'Mandatory Changes 17.2')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007187, 'LANGENG', NULL, 'CMN_STANDARD_VERSION', 'DESCRIPTION', 1069, 'Mandatory changes 18.1')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007602, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10003984, 'Compass Plus protocol version')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007856, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10008212, 'Parameter "Compass Plus protocol version" is not specifided for the current version of standart')
/
update com_i18n set text = 'Parameter[#4] is not specifided for the current version[#2] by host[#3] and inst[#1]' where id = 100000007856
/
