insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014009, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000902, 'POS Batch status')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014011, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000904, 'Batch is closed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014010, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000903, 'Batch is open')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014012, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10000905, 'POS is uploading settlement data')
/






---COM_DICTIONARY(IPKT)

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021557, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003207, 'ISO8583 POS key types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021558, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003208, 'Terminal MAC master key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021559, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003208, 'The key used for MAC key encryption if MAC key is transmission.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021560, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003209, 'Terminal PIN master key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021561, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003209, 'The key used for PIN key encryption if PIN key is transmission.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021562, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003210, 'Terminal MAC key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021563, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003210, 'The key is used to create MAC data for messages.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021564, 'LANGENG', null, 'COM_DICTIONARY', 'NAME', 10003211, 'Terminal PIN key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021565, 'LANGENG', null, 'COM_DICTIONARY', 'DESCRIPTION', 10003211, 'The key is used to encrypt PIN-block while PIN-block is transmitted.')
/


---COM_LOV
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021566, 'LANGENG', null, 'COM_LOV', 'NAME', 272, 'ISO8583 POS key types')
/


--- CMN_STANDARD
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values   (100000021568, 'LANGENG', null, 'CMN_STANDARD', 'DESCRIPTION', 1010, 'Standard for processing of different operations received from POS terminals.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021567, 'LANGENG', null, 'CMN_STANDARD', 'LABEL', 1010, 'BPC ISO8583 POS standard')
/


--- CMN_STANDARD_VERSION
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021569, 'LANGENG', null, 'CMN_STANDARD_VERSION', 'DESCRIPTION', 1011, 'Basic BPC ISO8583 POS standard version')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052772, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007012, 'SVFE POS batch file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052773, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10007012, 'Position file format for transmission of POS batch data from SVFE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052771, 'LANGENG', NULL, 'PRC_FILE_SAVER', 'NAME', 1037, 'POS batch file saver')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052770, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001003, 'POS batch loading (SVFE format)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052774, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1451, 'SVFE POS batch incoming file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052876, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10003096, 'POS batch support')
/
update com_i18n set text = 'POS batch downloading (SVFE format)' where id = 100000052770
/
update com_i18n set text = 'POS batch loading (SVFE format)' where id = 100000052770
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112490, 'LANGENG', NULL, 'RPT_REPORT', 'LABEL', 10000248, 'Unmatched POS batch and authorization records')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112500, 'LANGENG', NULL, 'RPT_TEMPLATE', 'LABEL', 10000347, 'Template for "Unmatched POS batch and authorization records"')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112491, 'LANGENG', NULL, 'RPT_PARAMETER', 'LABEL', 10004309, 'Institution')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112492, 'LANGENG', NULL, 'RPT_PARAMETER', 'LABEL', 10004310, 'Start date')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112493, 'LANGENG', NULL, 'RPT_PARAMETER', 'LABEL', 10004311, 'End date')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112494, 'LANGENG', NULL, 'RPT_PARAMETER', 'LABEL', 10004312, 'Mode')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113875, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10004481, 'Transaction type in POS Batch file')
/
