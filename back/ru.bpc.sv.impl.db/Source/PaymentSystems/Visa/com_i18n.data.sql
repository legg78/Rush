insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014033, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001986, 'BIN [#1] is not registered for network [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014041, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10001995, 'File from VISA with id=#2 and date=#1 is already processed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014046, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10002004, 'VISA BIN [#1] is not registered for the network [#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000014125, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10002111, '#1: VISA File has wrong format (#2 bad lines found)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133193, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009941, 'Unable to determine standard id for this network')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133202, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009943, 'TC 46 Member Settlement: Unknown report group/subgroup')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133203, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009944, 'TC 46 V4: TCR1 record not present')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133204, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009945, 'Visa original message not found')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133205, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009946, 'Security code for institution is wrong')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133206, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009947, 'Visa file corrupted because trailer BIN is incorrect')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133207, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009948, 'Test option parameter in Visa file is wrong')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133209, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009950, 'Unable to mark original message as returned')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000133210, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009951, 'Visa file corrupted because trailer date is incorrect')
/
---------- VIKT dictionary
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135079, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002905, 'Visa Key Types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135088, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002908, 'PIN encryption key that is used to transmit PIN block between card acquirer and VISA network.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135082, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002908, 'Acquirer Working Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135089, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002911, 'Key is used to generate and verify CVV2 value at VISA card issuer side.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135085, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002911, 'CVV2 Verification Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135090, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002910, 'Key is used to generate and verify CVV value at VISA card issuer side.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135084, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002910, 'CVV Verification Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135087, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002907, 'PIN encryption key that is used to transmit PIN block between card issuer and VISA network.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135081, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002907, 'Issuer Woking Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135083, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002909, 'PIN Verification Key')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135086, 'LANGENG', '', 'COM_DICTIONARY', 'DESCRIPTION', 10002906, 'Key is used to encrypt other keys while that keys are transmitted between VISA and other parties. This key is combined from three components. This combination can be done in manual way at HSM console.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135080, 'LANGENG', '', 'COM_DICTIONARY', 'NAME', 10002906, 'Zone Control Master Key')
/

-- VIB2 dictionary
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021528, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003196, 'Visa Base II dialects')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021529, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003197, 'Visa native')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021530, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003198, 'Way4 extension')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021964, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003273, 'VISA financial message status')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021965, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003274, 'Ready to unload')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021966, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003275, 'Unloaded')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021967, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003276, 'Processed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021968, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10003277, 'Invalid')
/

------------------ COM_LOV
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000135092, 'LANGENG', null, 'COM_LOV', 'NAME', 193, 'VISA Key Types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021531, 'LANGENG', NULL, 'COM_LOV', 'NAME', 270, 'VISA Base II dialects')
/



--- CMN_STANDARD
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020266, 'LANGENG', null, 'CMN_STANDARD', 'DESCRIPTION', 1004, 'Standard for online communication with VISA network, using BASE I protocol.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020265, 'LANGENG', null, 'CMN_STANDARD', 'LABEL', 1004, 'VISA BASE I standard')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021527, 'LANGENG', NULL, 'CMN_STANDARD', 'LABEL', 1008, 'VISA Base II')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022757, 'LANGENG', 'CMN_STANDARD', 'DESCRIPTION', 1011, 'Visa V.I.P. Full Service (SMS)')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022756, 'LANGENG', 'CMN_STANDARD', 'LABEL', 1011, 'Visa SMS')
/

--- CMN_STANDARD_VERSION
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020267, 'LANGENG', null, 'CMN_STANDARD_VERSION', 'DESCRIPTION', 1004, 'Base version for VISA BASE I standard')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022758, 'LANGENG', 'CMN_STANDARD_VERSION', 'DESCRIPTION', 1012, 'Base version')
/


--- CMN_PARAMETER
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020275, 'LANGENG', null, 'CMN_PARAMETER', 'CAPTION', 10001081, 'Acquirer institution ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020276, 'LANGENG', null, 'CMN_PARAMETER', 'DESCRIPTION', 10001081, 'Identifier of acquirer institution inside VISA network')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020277, 'LANGENG', null, 'CMN_PARAMETER', 'CAPTION', 10001082, 'Acquirer institution country code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020278, 'LANGENG', null, 'CMN_PARAMETER', 'CAPTION', 10001083, 'Forwarding institution ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020279, 'LANGENG', null, 'CMN_PARAMETER', 'DESCRIPTION', 10001083, 'Identifier of forwarding institution for acquirer in VISA network.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020280, 'LANGENG', null, 'CMN_PARAMETER', 'CAPTION', 10001084, 'Station ID (VISA access point)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020281, 'LANGENG', null, 'CMN_PARAMETER', 'DESCRIPTION', 10001084, 'Identifier of source station for VISA messages.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020282, 'LANGENG', null, 'CMN_PARAMETER', 'CAPTION', 10001085, 'VISA Interchange text format')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000020283, 'LANGENG', null, 'CMN_PARAMETER', 'DESCRIPTION', 10001085, 'Type of field format for several fields.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021532, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10001111, 'Dialect')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021939, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10001142, 'Retail CPS participation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021940, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10001143, 'ATM CPS participation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021941, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10001144, 'Acquirer business ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021944, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10001145, 'Security code')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022913, 'LANGENG', 'CMN_PARAMETER', 'CAPTION', 10001195, 'Acquirer institution ID')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022914, 'LANGENG', 'CMN_PARAMETER', 'DESCRIPTION', 10001195, 'Identifier of acquirer institution inside VISA network')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022915, 'LANGENG', 'CMN_PARAMETER', 'CAPTION', 10001196, 'Acquirer institution country code')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022916, 'LANGENG', 'CMN_PARAMETER', 'DESCRIPTION', 10001196, 'ISO 3166 3 digit country code of the acquirer')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022917, 'LANGENG', 'CMN_PARAMETER', 'CAPTION', 10001197, 'Forwarding institution ID')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022918, 'LANGENG', 'CMN_PARAMETER', 'DESCRIPTION', 10001197, 'Identifier of forwarding institution for acquirer in VISA network.')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022919, 'LANGENG', 'CMN_PARAMETER', 'CAPTION', 10001198, 'Station ID (VISA access point)')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022920, 'LANGENG', 'CMN_PARAMETER', 'DESCRIPTION', 10001198, 'Identifier of source station for VISA messages.')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022921, 'LANGENG', 'CMN_PARAMETER', 'CAPTION', 10001199, 'VISA Interchange text format')
/
insert into com_i18n (id, lang, table_name, column_name, object_id, text) values (100000022922, 'LANGENG', 'CMN_PARAMETER', 'DESCRIPTION', 10001199, 'Type of the visa message format')
/

--- PRC_PROCESS
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021946, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000841, 'VISA BASEII outgoing clearing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021948, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000842, 'VISA BASEII incoming clearing')
/

--- PRC_FILE
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021947, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1317, 'VISA BASEII clearing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000021949, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1318, 'VISA BASEII clearing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027279, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10001447, 'Acquirer password')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027280, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10001448, 'Directory URL')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027281, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10001449, 'Directory secondary URL')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027690, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10001535, 'CPS support indicator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027847, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000017, 'Loading Visa bin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027849, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000018, 'Loading Visa country')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027850, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000019, 'Loading Visa mcc')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000027851, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000020, 'Loading Visa currency')
/
-- ACAB dictionary
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000029523, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004245, 'Algorithm of calculation available balance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028104, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004003, 'Minimum')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028105, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004004, 'Average')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028106, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004005, 'Maximum')
/
-- COM_LOV for ACAB
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028108, 'LANGENG', NULL, 'COM_LOV', 'NAME', 343, 'Algorithm of calculation available balance')
/

-- VCPC
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028534, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004080, 'Visa card product code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028535, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004081, 'Visa Electron')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028536, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004082, 'undefine ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028537, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004083, 'Classic')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028538, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004084, 'Traditional')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028539, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004085, 'Infinite')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028540, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004086, 'Platinum')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028541, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004087, 'Gold')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028542, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004088, 'Purchasing')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028611, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000852, 'Prepare data for quarterly report VISA')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000028646, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004093, 'VISA quarterly report rate type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031066, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002036, 'Member message text')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031067, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002037, 'Documentation indicator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031068, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002038, 'Special chargeback indicator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031071, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1515, 'Init Visa first chargeback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031072, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1516, 'Init Visa second chargeback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031073, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1517, 'Create Visa first chargeback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031074, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1518, 'Create Visa second chargeback')
/
delete from com_i18n where id in (100000021964,100000021965,100000021966,100000021967,100000021968)
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031106, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1519, 'Create Visa first presentment reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031107, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1520, 'Create Visa second presentment reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031108, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1521, 'Init Visa first presentment reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031109, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1522, 'Init Visa second presentment reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031110, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1523, 'Init Visa second presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031111, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1524, 'Create Visa second presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031112, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1525, 'Init Visa presentment chargeback reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031113, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1526, 'Create Visa second presentment chargeback reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031506, 'LANGENG', null, 'COM_LOV', 'NAME', 396, 'Visa documentation indicators')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031502, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004683, 'Visa documentation indicators')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031507, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004687, 'No supporting documentation is provided')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031508, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004688, 'Supporting documentation to follow')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031509, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004689, 'Invalid Acquirer Reference Number and no supporting documentation was required or received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031510, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004690, 'Invalid Acquirer Reference Number and supporting documentation was received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031511, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004691, 'No supporting documentation was received for prior chargeback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031512, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004692, 'No supporting documentation required')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032455, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004871, 'Fraud Type (Visa)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032456, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004872, 'Card reported lost')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032457, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004873, 'Card reported stolen')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032458, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004874, 'Card not received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032459, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004875, 'Fraudulent application')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032460, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004876, 'Issuer reported counterfeit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032461, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004877, 'Miscellaneous')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032462, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004878, 'Fraudulent use of account number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032463, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004879, 'Notification Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032464, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004880, 'addition')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032465, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004881, 'addition of subsequent identical (duplicate) transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032466, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004882, 'change')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032467, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004883, 'delete')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032468, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004884, 'reactivate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032469, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004885, 'Issuer generated authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032470, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004886, 'Issuer authorized transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032471, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004887, 'Transaction authorized but not by issuer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032472, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004888, 'Transaction not authorized')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032473, 'LANGENG', NULL, 'COM_LOV', 'NAME', 416, 'Visa fraud type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032474, 'LANGENG', NULL, 'COM_LOV', 'NAME', 417, 'Visa fraud notification code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032475, 'LANGENG', NULL, 'COM_LOV', 'NAME', 418, 'Visa fraud issuer generated authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032476, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002206, 'Fraud type (Visa)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032477, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002207, 'Issuer generated authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032478, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002208, 'Notification Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032479, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1531, 'Init Visa fraud reporting')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032480, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1532, 'Create Visa fraud reporting')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032482, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1288, 'Visa outgoing format')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032803, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004980, 'Visa reason code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032804, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004981, 'Services Not Provided or Merchandise Not Received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032805, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004982, 'Cancelled Recurring Transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032806, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004983, 'Not as Described or Defective Merchandise')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032807, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004984, 'Fraudulent Multiple Transactions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032808, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004985, 'Illegible Fulfillment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032809, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004986, 'Counterfeit Transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032810, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004987, 'Card Recovery Bulletin or Exception File')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032811, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004988, 'Declined Authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032812, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004989, 'No Authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032813, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004990, 'Expired Card')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032814, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004991, 'Late Presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032815, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004992, 'Transaction Not Recognized')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032816, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004993, 'Incorrect Currency or Transaction Code or Domestic Transaction Processing Violation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032817, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004994, 'Non-Matching Account Number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032818, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004995, 'Service Code Violation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032819, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004996, 'Incorrect Transaction Amount or Account Number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032820, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004997, 'Fraud - Card-Present Environment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032821, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004998, 'Duplicate Processing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032822, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10004999, 'Fraud - Card-Absent Environment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032823, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005000, 'Credit Not Processed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032824, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005001, 'Paid By Other Means')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032825, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005002, 'Non-Receipt of Cash or Load Transaction Value at ATM or Load Device')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032826, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005003, 'Merchant Fraud Performance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032827, 'LANGENG', NULL, 'COM_LOV', 'NAME', 428, 'Visa reason code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000032929, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005010, 'Visa base II')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000044909, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10002359, 'Collection only')
/
update com_i18n set text = 'Processing BIN' where id = 100000021941
/
update com_i18n set text = 'Acquirer business ID' where id = 100000020275
/
update com_i18n set text = 'Notification code' where id = 100000032463
/
update com_i18n set text = 'Addition' where id = 100000032464
/
update com_i18n set text = 'Addition of subsequent identical (duplicate) transaction' where id = 100000032465
/
update com_i18n set text = 'Change' where id = 100000032466
/
update com_i18n set text = 'Delete' where id = 100000032467
/
update com_i18n set text = 'Reactivate' where id = 100000032468
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045132, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005215, 'Excluded transaction identifier reason')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045152, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005216, 'Original not cleared through VisaNet')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045134, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005217, 'No transaction identifier')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045135, 'LANGENG', NULL, 'COM_LOV', 'NAME', 118, 'Excluded transaction identifier reason')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045352, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011367, 'Reversal amount greater then original amount')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136802, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1544, 'Init Visa Fee Collection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136803, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1545, 'Create Visa Fee Collection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136801, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1004, 'Fee Collection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136805, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1546, 'Init Visa Funds Disbursement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136806, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1547, 'Create Visa Funds Disbursement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136809, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005355, 'Fee Collection/Funds Disbursement reason code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136810, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005356, 'Telex, Telephone and Cable Charges')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136811, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005357, 'Auto-Telex Charges')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136812, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005358, 'Lost/Stolen Card Report Fees')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136813, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005359, 'Merchant Service Fees')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136814, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005360, 'Recovered Card Handling Fees/Rewards')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136815, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005361, 'Invalid Cab Chargeback Handling Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136816, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005362, 'Recovery of Microfilm Copy/Original Fees')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136817, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005363, 'Premium Card Guaranty Check')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136818, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005364, 'Emergency Replacement Card Distribution Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136819, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005365, 'Emergency Cash Disbursement Handling Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136820, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005366, 'Arbitration Case Decision and/or Request Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136821, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005367, 'Incorrect Merchant Identification/Transaction Date Handling Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136822, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005368, 'Funds Disbursement Transactions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136823, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005369, 'Invalid Chargeback Handling Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136824, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005370, 'Bill Payment Service (Canada and Brazil only)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136825, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005371, 'Pre-arbitration Settlement Funds Disbursement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136826, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005372, 'Visa TravelMoney Fees')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136827, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005373, 'Prepaid Revenue Allocation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136828, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005374, 'Prepaid Funds Collection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136829, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005375, 'Card Recovery Bulletin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136830, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005376, 'Visa Integrated Billing Statement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136831, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005377, 'Supermarket Incentive Program Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136832, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005378, 'Arbitration Request/Review')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136833, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005379, 'DMSC Access Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136834, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005380, 'Miscellaneous Fees or Charges')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136835, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005381, 'Issuers Clearinghouse Service Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136836, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005382, 'Risk Identification Service Merchant Fees')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136837, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005383, 'Late Settlement Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136838, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005384, 'Visa Account Tracking Service')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136839, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005385, 'Emergency Travelers Cheque Refund Handling Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136840, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005386, 'Returned Guaranteed Check')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136841, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005387, 'Value-Added Tax')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136842, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005388, 'VSIL Fee Collection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136843, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005389, 'ISO/Non-Member Agent Registration Fee/Annual Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136844, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005390, 'Chargeback Handling Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136845, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005391, 'Fulfilment Incentive Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136846, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005392, 'VisaNet Copy Request and Fulfilment Service Monthly Access and Activity Charges')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136847, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005393, 'Non-fulfilment Incentive Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136848, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005394, 'Merchant Review Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136849, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005395, 'Membership Compliance Fees and Penalties')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136850, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005396, 'BIN Licensing and Administration Program Fees')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136851, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005397, 'Sponsored Member Registration Fees')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136852, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005398, 'Merchant Data Inaccuracy. DMSC checks only for the value.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136853, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005399, 'Interchange Data Forms')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136854, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005400, 'Service Fees/Late Payments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136855, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005401, 'Indemnification')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136856, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005402, 'Visa TravelMoney Issuer Reimbursement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136857, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005403, 'Collateral Funds')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136858, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005404, 'Stored-Value Card Purchase Settlement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136859, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005405, 'Stored-Value Card Allocated Discrepancies')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136860, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005406, 'Stored-Value Card Manual Adjustment Settlement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136861, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005407, 'Stored-Value Card Reserved')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136862, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005408, 'Corporate Indemnification of Settlement Risk')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136863, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005409, 'Promotion Credit Reward Funding')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136864, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005410, 'ATM Cash Disbursement Issuer Credit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136865, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005411, 'Member-Provided Reimbursement Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136866, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005412, 'Visa Reward')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136867, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005413, 'Visa Reward Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136868, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005414, 'Cardholder Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136869, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005415, 'Cardholder Fee Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136870, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005416, 'Cardholder Credit/Rebate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136871, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005417, 'Cardholder Credit/Rebate Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136872, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005418, 'STAR Manual Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136873, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005419, 'PULSE Manual Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136874, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005420, 'NYCE Manual Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136875, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005421, 'VISA Network Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136876, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005422, 'ACCEL Manual Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136877, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005423, 'AFFN Manual Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136878, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005424, 'ALASKA Option Manual Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136879, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005425, 'CU-24 Network Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136880, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005426, 'EBT Manual Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136881, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005427, 'MAESTRO Manual Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136882, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005428, 'NETS Manual Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136883, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005429, 'Visa Purchasing VAT Remedy')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136884, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005430, 'Visa Purchasing VAT Remedy (Reversal)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136885, 'LANGENG', NULL, 'COM_LOV', 'NAME', 47, 'Fee Collection/Funds Disbursement reason code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000136897, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1005, 'Funds disbursement transactions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045477, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1006, 'Transmit monetary credits')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045481, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1549, 'Create Visa transmit monetary credits')
/
update com_i18n set text = 'Funds Disbursement reversal' where id = 100000136897
/
update com_i18n set text = 'Funds Disbursement' where id = 100000045477
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045635, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011472, 'VISA_ACQ_BUSINESS_ID_NOT_FOUND[#1][#2][#3]')
/
delete com_i18n where id = 100000133204
/
update com_i18n set text = 'Acquirer business identifier is not found. Institution identifier [#1], Standard identifier [#2], Host identifier [#3].' where id = 100000045635
/
delete com_i18n where id = 100000046163
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046163, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009431, 'BIN for the Processing Centre not defined')
/
delete com_i18n where id = 100000046164
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046164, 'LANGENG', null, 'CMN_PARAMETER', 'CAPTION', 10002710, 'Acquirer institution ID')
/
update com_i18n set text = 'VISA BINs loading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000017 and lang = 'LANGENG'
/
update com_i18n set text = 'VISA countries loading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000018 and lang = 'LANGENG'
/
update com_i18n set text = 'VISA MCCs loading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000019 and lang = 'LANGENG'
/
update com_i18n set text = 'VISA currencies loading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000020 and lang = 'LANGENG'
/
update com_i18n set text = 'VISA BASEII clearing file unloading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000841 and lang = 'LANGENG'
/
update com_i18n set text = 'VISA BASEII clearing file loading' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000842 and lang = 'LANGENG'
/
update com_i18n set text = 'VISA quarterly report aggregation' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000852 and lang = 'LANGENG'
/
delete com_i18n where id = 100000046397
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046397, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005744, 'Acquirer reported counterfeit')
/
delete from com_i18n where id = 100000045481
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046389, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000343, 'View VISA financial messages')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046629, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005763, 'Visa Collection Only Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046630, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005764, 'No Collection Only')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046631, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005765, 'No Withdrawal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046632, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005766, 'All operetion')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046633, 'LANGENG', NULL, 'COM_LOV', 'NAME', 470, 'Visa Collection only mode')
/
update com_i18n set text = 'Visa Chargeback reason codes' where id in (100000032803, 100000032827)
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046651, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005768, 'Visa Request for Copy reason codes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046652, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005769, 'IIAS (Healthcare Auto-substantiation) request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046653, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005770, 'Request for copy bearing signature')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046654, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005771, 'T and E Document request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046655, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005772, 'Cardholder request due to dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046656, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005773, 'Legal process or fraud analysis request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046657, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005774, 'Repeat request for copy/Legal process request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046658, 'LANGENG', NULL, 'COM_LOV', 'NAME', 99, 'Visa Request for Copy reason codes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046659, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002742, 'Issuer RFC BIN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046660, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002743, 'Issuer RFC Sub-Address')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046661, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002744, 'Requested Fulfillment Method')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046662, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002745, 'Established Fulfillment Method')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046663, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002746, 'Fax Number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046664, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10002747, 'Contact for Information')
/
delete from com_i18n where id = 100000028967
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046665, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1555, 'Create Visa Retrieval Request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046666, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1556, 'Init Visa Retrieval Request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137032, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005790, 'Tieto')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046944, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10002777, 'VISA Quarterly Report Name')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046935, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005835, 'Visa Quarterly Report')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046936, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005836, 'Acquiring transaction volumes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046937, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005837, 'Merchant Category Groups')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046938, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005838, 'Merchant and member information')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046939, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005839, 'Schedule F')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046940, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005840, 'Monthly issuing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046941, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005841, 'Card issuance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046942, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005842, 'Schedule A,E')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046943, 'LANGENG', NULL, 'COM_LOV', 'NAME', 478, 'VISA Quarterly Report list')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045481, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1549, 'Create Visa transmit monetary credits')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049680, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2345, 'Fee settings')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049681, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2346, 'Operations')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049682, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2347, 'Process log')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049683, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2348, 'General settings')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049684, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000372, 'View Visa interchange fees')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049685, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000373, 'View Visa interchange operations')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049686, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000374, 'View MasterCard process log')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049687, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000375, 'View MasterCard module general settings')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049872, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2355, 'Aggregation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049873, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000381, 'View Visa module aggregation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049888, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10002840, 'Visa settings')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049889, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10002841, 'Network ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050110, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2367, 'Fee criterias')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050111, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000400, 'View Visa interchange fee criterias')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050136, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10002858, 'Parent network identifier')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050269, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2371, 'VSS reports')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050268, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000404, 'View VISA VSS reports')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050292, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006448, 'VISA Business Transaction Type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050294, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006451, 'Purchase')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050295, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006452, 'VisaPhone')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050296, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006453, 'Quasi-cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050297, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006454, 'DDS On-Us')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050298, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006455, 'DDS Participate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050299, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006456, 'DDS Merchant Issuer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050300, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006457, 'NYCE purchase')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050301, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006458, 'PULSE purchase')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050302, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006459, 'STAR purchase')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050303, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006460, 'ACCEL PURCHASE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050304, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006461, 'AFFN PURCHASE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050305, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006462, 'ALASKA OPTION PURCHASE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050306, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006463, 'CU24 PURCHASE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050307, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006464, 'EBT POS PURCHASE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050308, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006465, 'MAESTRO PURCHASE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050309, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006466, 'NETS PURCHASE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050310, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006467, 'NYCE merch return')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050311, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006468, 'PULSE merch return')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050312, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006469, 'STAR merch return')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050313, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006470, 'ACCEL MERCH RETURN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050314, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006471, 'AFFN MERCH RETURN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050315, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006472, 'ALASKA OPT MERCH RTRN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050316, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006473, 'CU24 MERCH RETURN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050317, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006474, 'EBT POS MERCH RETURN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050318, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006475, 'MAESTRO MERCH RETURN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050319, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006476, 'NETS MERCH RETURN')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050320, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006477, 'NYCE preauth')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050321, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006478, 'PULSE preauth')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050322, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006479, 'STAR preauth')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050323, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006480, 'ACCEL PRE-AUTH')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050324, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006481, 'AFFN PRE-AUTH')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050325, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006482, 'ALASKA OPTION PRE-AUTH')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050326, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006483, 'CU24 PRE-AUTH')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050327, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006484, 'EBT POS PRE-AUT')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050328, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006485, 'MAESTRO PRE-AUT')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050329, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006486, 'NETS PRE-AUTH')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050330, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006487, 'NYCE decline')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050331, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006488, 'PULSE decline')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050332, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006489, 'STAR decline')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050333, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006490, 'ACCEL DECLINE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050334, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006491, 'AFFN DECLINE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050335, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006492, 'ALASKA OPTION DECLINE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050336, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006493, 'CU24 DECLINE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050337, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006494, 'EBT POS DECLINE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050338, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006495, 'MAESTRO DECLINE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050339, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006496, 'NETS DECLINE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050340, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006497, 'Merchandise Credit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050341, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006498, 'Quasi-cash Credit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050342, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006499, 'Manual Cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050343, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006500, 'ATM Cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050344, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006501, 'ATM Deposits')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050345, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006502, 'POS Check')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050346, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006503, 'Original Credit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050347, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006504, 'Payment Order Sendback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050348, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006505, 'Payment Order')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050349, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006506, 'Payment Order Notifiation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050350, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006507, 'Prepaid Loads /Reloads')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050351, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006508, 'Account Payment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050352, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006509, 'ACCEL PINLESS BILL PAY')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050353, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006510, 'ACCEL PINLESS BILL PAY DEC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050354, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006511, 'PWP STLMT RC=6000')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050355, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006512, 'PWP STLMT RV RC=6010')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050356, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006513, 'PWP STMT CR RC=6020')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050357, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006514, 'PWP STMT CR RV RC=6030')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050358, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006515, 'VISA AWARD')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050359, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006516, 'VISA AWARD REVERSAL')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050360, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006517, 'VISA AWARD OFFSET')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050361, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006518, 'VISA AWARD OFFSET REV')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050362, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006519, 'Cardholder fee rc=6100')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050363, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006520, 'Cardholder fee rc=6110')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050364, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006521, 'Cardholder fee rc=6120')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050365, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006522, 'Cardholder fee rc=6130')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050366, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006523, 'VISA extra rc=6080')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050367, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006524, 'VISA extra rc=6085')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050368, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006525, 'PWP STLMT RC=6000')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050369, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006526, 'PWP STLMT RV RC=6010')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050370, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006527, 'PWP STMT CR RC=6020')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050371, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006528, 'PWP STMT CR RV RC=6030')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050372, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006529, 'VISA AWARD')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050373, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006530, 'VISA AWARD REVERSAL')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050374, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006531, 'VISA AWARD OFFSET')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050375, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006532, 'VISA AWARD OFFSET REV')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050376, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006533, 'Rebate credit rc=6100')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050377, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006534, 'Rebate credit rc=6110')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050378, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006535, 'Rebate credit rc=6120')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050379, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006536, 'Rebate credit rc=6130')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050380, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006537, 'VISA extra rc=6080')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050381, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006538, 'VISA extra rc=6085')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050382, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006539, 'COLL/DISB DECLINE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050383, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006540, 'Returned Item')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050384, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006541, 'Returned Item')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050385, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006542, 'Returned Item')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050386, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006543, 'Reclassifiation Advice')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050387, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006544, 'ISSUER LOYALTY PGM')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050388, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006545, 'PROVIDER LOYALTY PGM')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050389, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006546, 'VISA LOYALTY PGM')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050390, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006547, 'MERCHANT LOYALTY PGM')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050391, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006548, 'ICS Outgoing/Query')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050392, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006549, 'ICS Incoming/Resp')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050393, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006550, 'Risk Management')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050394, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006551, 'Multipurpose Message')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050395, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006552, 'Request For Copy')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050396, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006553, 'RFC Fulfilment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050397, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006554, 'Fraud Advice')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050398, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006555, 'Merch File Upd (Mand)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050399, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006556, 'Merch File Upd (Opt)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050400, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006557, 'Batch Acknowledgment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050401, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006558, 'General Delivery Rpts')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050402, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006559, 'Sett Rpts (Mach Read)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050403, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006560, 'Sett Rpts (Print Imag)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050404, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006561, 'BASE I Advice Records')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050405, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006562, 'Text Message')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050406, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006563, 'Request For Original')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050407, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006564, 'Request For Photocopy')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050408, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006565, 'Confimation Request')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050409, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006566, 'Table Updates')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050410, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006567, 'RCRF Updates')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050411, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006568, 'Currency Conv Rate Upd')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050412, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006569, 'Data Capture Advice')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050413, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006570, 'National Sett Adv')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050414, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006571, 'Interface Advice')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050415, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006572, 'VISA extras fee msg')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050416, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006573, 'Prepaid Non-Financials')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050417, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006574, 'POS Authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050418, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006575, 'POS Preauthorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050419, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006576, 'POS Balance Inquiry')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050420, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006577, 'POS Authorization Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050421, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006578, 'POS Preauthorization Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050422, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006579, 'POS Decline')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050423, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006580, 'DDS On-Us Preauthorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050424, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006581, 'DDS On-Us Decline')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050425, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006582, 'DDS Participant Preauthorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050426, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006583, 'DDS Participant Decline')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050427, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006584, 'DDS MIS Preauthorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050428, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006585, 'DDS MIS Decline')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050429, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006586, 'DDS Acquirer Specifid Destination')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050430, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006587, 'Member Sweepstakes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050431, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006588, 'Visa Sweepstakes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050432, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006589, 'ATM Authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050433, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006590, 'ATM Balance Inquiry')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050434, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006591, 'ATM Authorization Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050435, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006592, 'ATM Decline')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050436, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006593, 'ATM Transfer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050437, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006594, 'PIN CHANGE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050438, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006595, 'PIN UNBLOCK')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050439, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006596, 'ACCEL POS BALANCE INQ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050440, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006597, 'AFFN POS BALANCE INQ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050441, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006598, 'EBT POS BALANCE INQ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050442, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006599, 'AL OPT POS BALANCE INQ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050443, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006600, 'CU24 POS BALANCE INQ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050444, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006601, 'MAESTRO POS BAL INQ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050445, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006602, 'NET POS BALANCE INQ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050446, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006603, 'Visa ePay Transfer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050447, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006604, 'File Maintenance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050448, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006605, 'STAR POS BALANCE INQ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050449, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006606, 'PULSE POS BALANCE INQ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050450, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006607, 'NYCE POS BALANCE INQ')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050451, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006608, 'Other Transactions')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050452, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006609, 'VISA Business Transaction Cycle Codes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050453, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006610, 'Originals')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050454, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006611, 'Chargebacks')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050455, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006612, 'Representments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050456, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006613, 'Second Chargebacks')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050457, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006614, 'Debit Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050458, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006615, 'Credit Adjustments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050459, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006616, 'The transaction does not have a cycle')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050460, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006617, 'VISA Jurisdictions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050461, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006618, 'Visa International')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050462, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006619, 'Visa Canada')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050463, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006620, 'Visa CEMEA')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050464, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006621, 'Visa EU')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050465, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006622, 'Visa AP')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050466, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006623, 'Visa LAC')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050467, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006624, 'Visa USA')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050468, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006625, 'Plus USA')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050469, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006626, 'Interlink USA')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050470, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006627, 'Interlink International')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050471, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006628, 'Visa Germany')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050472, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006629, 'Visa UK')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050473, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006630, 'Visa Charge Types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050474, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006631, 'BASE II Processing Charges')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050475, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006632, 'International Acquiring Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050476, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006633, 'Special Airline Fees (SAF)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050477, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006634, 'Currency Conversion Fees')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050478, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006635, 'Currency Conversion Fee Allocations')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050479, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006636, 'Returned Item Charges')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050480, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006637, 'Escrow')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050481, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006638, 'Currency Rate Difference')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050482, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006639, 'Cross-Border USD')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050483, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006640, 'Cross-Border USD Allocation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050484, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006641, 'International Service Assessment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050485, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006642, 'International Service Assessment Allocation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050486, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006643, 'Visa processing charge')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050487, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006644, 'Network processing charge')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050488, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006645, 'ISA Credit Rebate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050489, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006646, 'Fx Timing Difference')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050490, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006647, 'Cross Currency Fx Difference')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050491, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006648, 'Candidate Fx Difference')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050492, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006649, 'No Conversion Difference')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050493, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006650, 'Timing Cross Difference')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050494, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006651, 'Timing Candidate Difference')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050495, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006652, 'Timing Cross-Candidate Difference')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050496, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006653, 'No Conversion Cross Rate Diff')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050497, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006654, 'ISA Single Currency Non-Internet')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050498, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006655, 'Issuer Region ISA Allocation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050499, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006656, 'ISA Acquirer Redirected')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050500, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006657, 'Issuer ISA Charge Single Currency')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050501, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006658, 'Issuer ISA Allocation Single Currency')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050502, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006659, 'Acquirer ISA Charge Multicurrency')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050503, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006660, 'AISA Allocation Multicurrency Cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050504, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006661, 'Acquirer ISA Charge Single Currency')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050505, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006662, 'AISA Allocation Single Currency Cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050506, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006663, 'ISA Allocation Single Currency Internet')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050507, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006664, 'AISA Allocation Multicurrency POS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050508, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006665, 'AISA Allocation Single Currency POS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050509, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006666, 'Network Security')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050510, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006667, 'Acquirer International E-Commerce')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050511, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006668, 'Network Premier Issuer')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050512, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006669, 'ATM Fees Differential, Interregion')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050513, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006670, 'Rounding Difference')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050514, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006671, 'US Fee Differential')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050515, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006672, 'US SMIR Fee Differentials')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050516, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006673, 'ATM Fees Differential, Intraregion')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050517, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006674, 'Consumer fee differentials')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050518, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006675, 'Rewards fee differentials')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050519, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006676, 'AP Intraregion Fee Differential')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050520, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006677, 'Obsolete')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050521, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006678, 'Other')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050522, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006679, 'Visa Transaction Dispositions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050523, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006680, 'Sent to Visa')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050524, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006681, 'Sent to Visa, To Warehouse')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050525, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006682, 'Sent to Visa, To Deferred')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050526, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006683, 'Sent to Visa, To CRS (Chargeback Reduction Service)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050527, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006684, 'Sent to Visa, Accepted From Warehouse')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050528, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006685, 'Sent to Visa, Returned From Warehouse')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050529, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006686, 'Sent to Visa, From Deferred')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050530, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006687, 'Sent to Visa, Accepted From CRS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050531, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006688, 'Sent to Visa, Returned From CRS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050532, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006689, 'Sent to Visa and Sent to Settlement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050533, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006690, 'Total Sent to Visa')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050534, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006691, 'Received From Visa')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050535, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006692, 'Received From Visa, To Deferred')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050536, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006693, 'Received From Visa, To CRS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050537, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006694, 'Received From Visa, From Deferred')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050538, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006695, 'Received From Visa, Current Cycle Returned')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050539, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006696, 'Received From Visa, Returned From CRS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050540, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006697, 'Received From Visa, Returned From Warehouse')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050541, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006698, 'Received From Visa and Sent to Settlement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050542, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006699, 'Total Received from Visa')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050543, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006700, 'Total Sent to Settlement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050544, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006701, 'Total Clearing Only Financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050545, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006702, 'Total Nonfiancial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050546, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006703, 'Total Clearing Only Nonfiancial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050547, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006704, 'Total Transactions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050548, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006705, 'From Warehouse to Deferred')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050549, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006706, 'From Warehouse to CRS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050550, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006707, 'From CRS Accepted to Warehouse')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050551, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006708, 'From CRS Accepted to Deferred')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050552, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006709, 'Disposition Unknown')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050626, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2374, 'Rejected')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050627, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000413, 'View Visa rejects')
/
update com_i18n set text='View Visa process log' where object_id=10000374 and lang='LANGENG' and table_name='ACM_PRIVILEGE'
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050655, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10002871, 'Euro Settlement')
/
update com_i18n set text='Fee criteria' where id=100000050110
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050657, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10002872, 'Set logical connection when installing communication connection')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050698, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10002879, 'Period between sending echo tests')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050699, 'LANGENG', NULL, 'CMN_PARAMETER', 'DESCRIPTION', 10002879, 'Count of seconds between echo-tests sending. Value 0 means turn off the echo-test sending')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050702, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10002880, 'Period between sending echo tests')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050703, 'LANGENG', NULL, 'CMN_PARAMETER', 'DESCRIPTION', 10002880, 'Count of seconds between echo-tests sending. Value 0 means turn off the echo-test sending')
/


insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050844, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006828, 'Interchange Network fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050845, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006829, 'Optional Issuer Fee')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050846, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006830, 'International Standard Assessment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050847, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006831, 'International Acquiring Fee')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050553, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009505, 'Unable to mark original message as rejected')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050556, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000934, 'VISA Rejected Item Files loading')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050557, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1403, 'VISA Rejected Item')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050577, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10002865, 'Validate records')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050578, 'LANGENG', NULL, 'PRC_PARAMETER', 'DESCRIPTION', 10002865, 'If validate records set to true - clearing files loading processes will check every record on format of each field specified in validation rules')
/
delete com_i18n where id = 100000050923
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050923, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006832, 'Visa financial record')
/
update com_i18n set text = 'TC 46, V4: TCR1 record not present in file with ID [#1], record number [#2]' where id = 100000133203
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051256, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006847, 'International airline program autorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051257, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006848, 'Visa Cash Load Settlement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051293, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006849, 'VISA settlement buy rate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051294, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006850, 'VISA settlement sell rate')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051412, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2378, 'Country settings')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051758, 'LANGENG', NULL, 'RPT_REPORT', 'LABEL', 10000157, 'VISA reconciliation with VSS-900')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051761, 'LANGENG', NULL, 'RPT_PARAMETER', 'LABEL', 10003015, 'Institution')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051769, 'LANGENG', NULL, 'RPT_PARAMETER', 'LABEL', 10003018, 'Reconciliation date')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051762, 'LANGENG', NULL, 'RPT_TEMPLATE', 'LABEL', 10000233, 'VISA reconciliation with VSS-900')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051743, 'LANGENG', NULL, 'COM_ARRAY', 'LABEL', 10000040, 'VSS Business Transaction Types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051744, 'LANGENG', NULL, 'COM_ARRAY', 'DESCRIPTION', 10000040, 'VisaNet Settlement Service Business Transaction Types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051745, 'LANGENG', NULL, 'COM_ARRAY_TYPE', 'LABEL', 1036, 'VSS Codes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051746, 'LANGENG', NULL, 'COM_ARRAY_TYPE', 'DESCRIPTION', 1036, 'VisaNet Settlement Service Codes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051747, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002041, 'Purchase')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051748, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002042, 'Quasi-cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051749, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002043, 'Merchandise Credit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051750, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002044, 'Quasi-cash Credit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051751, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002045, 'Manual Cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051752, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002046, 'ATM Cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051753, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002047, 'Original Credit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051754, 'LANGENG', NULL, 'COM_ARRAY_CONVERSION', 'LABEL', 1015, 'VSS Business Transaction Types')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051865, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006887, 'Visa product')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051866, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006888, 'Visa Classic(F)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051867, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006889, 'Visa Gold (P)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051868, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006890, 'Visa Platinum (N)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051869, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006891, 'Visa Rewards (N1)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051870, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006892, 'Visa Select (N2)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051871, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006893, 'Visa Infinite (I)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051872, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006894, 'Visa Infinite Privilege (I1)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051873, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006895, 'UHNW (I2)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051874, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006896, 'Visa Signature (C)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051875, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006897, 'Visa Signature Preferred (D)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051876, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006898, 'Visa Electron (L)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051877, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006899, 'Visa Traditional (A)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051878, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006900, 'Visa Traditional Rewards (B)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051879, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006901, 'Visa Healthcare (J3)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051880, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006902, 'Visa Travel Money (U)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051881, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006903, 'Visa V Pay (V)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051882, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006904, 'Visa Corporate TE (K)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051883, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006905, 'Visa Government Corporate TE (K1)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051884, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006906, 'Visa Purchasing (S)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051885, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006907, 'Health Care (HC)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051886, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006908, 'Construction (CS)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051887, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006909, 'Distribution (DS)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051888, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006910, 'Visa Purchasing with Fleet (S1)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051889, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006911, 'Visa Government Purchasing (S2)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051890, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006912, 'Visa Government Purchasing with Fleet (S3)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051891, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006913, 'Commercial Business Loan (S4)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051892, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006914, 'Commercial Transport EBT (S5)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051893, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006915, 'Business Loan (S6)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051894, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006916, 'Visa Business (G)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051895, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006917, 'Visa Signature Business (G1)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051896, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006918, 'Visa Platinum Business (G3)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051897, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006919, 'Visa Infinite Business (G4)')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050565, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006710, 'Reject type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050569, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006714, 'Reject resolution mode')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050573, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006718, 'Reject status')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050606, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006730, 'Reject codes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050566, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006711, 'Primary validation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050567, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006712, 'Business validation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050568, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006713, 'Regulators schemes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050570, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006715, 'Forward')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050571, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006716, 'Cancelled')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050572, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006717, 'No actions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050574, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006719, 'Opened')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050575, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006720, 'Closed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050576, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006721, 'Resolved')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050607, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006731, 'Rejected at validation rules checking')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050647, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006736, 'VISA Rejected data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050648, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006737, 'MasterCard Rejected data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000050649, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006738, 'Reject registration')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052742, 'LANGENG', NULL, 'ACM_ROLE', 'NAME', 1002, 'Visa operator role')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052743, 'LANGENG', NULL, 'ACM_ROLE', 'DESCRIPTION', 1002, 'Management of Visa payment system')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052973, 'LANGENG', NULL, 'COM_ARRAY_TYPE', 'LABEL', 1042, 'Visa reason codes that send card number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052974, 'LANGENG', NULL, 'COM_ARRAY_TYPE', 'DESCRIPTION', 1042, 'The Visa outgoing clearing file contains card number for these reason codes only.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052971, 'LANGENG', NULL, 'COM_ARRAY', 'LABEL', 10000049, 'Visa reason codes that send card number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052972, 'LANGENG', NULL, 'COM_ARRAY', 'DESCRIPTION', 10000049, 'The Visa outgoing clearing file contains card number for these reason codes only.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052975, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002129, '0100')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052976, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002130, '0110')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052977, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002131, '0130')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052978, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002132, '0150')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052979, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002133, '0160')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052980, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002134, '0170')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052981, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002135, '0190')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052982, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002136, '0200')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052983, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002137, '0210')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052984, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002138, '0220')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052985, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002139, '0230')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052986, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002140, '0240')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052987, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002141, '0300')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052988, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002142, '0350')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052989, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002143, '5150')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052990, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002144, '5320')
/
delete from com_i18n where id = 100000049683
/
delete from com_i18n where id = 100000051412
/
delete com_i18n where id = 100000049687
/
delete com_i18n where id = 100000051413
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054668, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007231, 'Co-Brand')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054669, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007232, 'Acquiring V PAY')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054670, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007233, 'Acquiring Contactless')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054671, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007234, 'Acquiring E-Commerce')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054672, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007235, 'Acquiring ATM')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054673, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007236, 'Acquired Data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054674, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007237, 'MOTO and Recurring')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055610, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007403, 'Visa Message Reason Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055611, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007404, 'Fraud')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055612, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007405, 'Authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055613, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007406, 'Processing error')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055614, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007407, 'Consumer dispute')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055620, 'LANGENG', NULL, 'COM_LOV', 'NAME', 551, 'Visa Message Reason Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055621, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007408, 'Visa Dispute Statuses')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055622, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007409, 'Dispute Financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055623, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007410, 'Dispute Financial Reversal—Recall')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055624, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007411, 'Dispute Financial Reversal—Pre-arbitration Acceptance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055625, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007412, 'Dispute Financial Reversal—Arbitration Decision')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055626, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007413, 'Dispute Response Financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055627, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007414, 'Dispute Response Financial Reversal—Recall')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055628, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007415, 'Dispute Response Financial Reversal—Pre-arbitration Acceptance')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055629, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007416, 'Dispute Response Financial Reversal—Arbitration Decision')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055630, 'LANGENG', NULL, 'COM_LOV', 'NAME', 552, 'Visa Dispute Statuses')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055647, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10003312, 'VCR Dispute enable')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055660, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10003313, 'VCR Message reason code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055661, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10003314, 'VCR Dispute condition')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055662, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10003315, 'VROL Financial ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055663, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10003316, 'VROL Case Number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055664, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10003317, 'VROL Bundle Case Number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055665, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10003318, 'VROL Client Case Number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055672, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1647, 'Init Visa VCR dispute response financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055673, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1648, 'Init Visa VCR dispute financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055674, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1649, 'Init Visa VCR dispute response financial reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055675, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1650, 'Init Visa VCR dispute financial reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055676, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1651, 'Create Visa VCR dispute response financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055677, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1652, 'Create Visa VCR dispute financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055678, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1653, 'Create Visa VCR dispute response financial reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055679, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1654, 'Create Visa VCR dispute financial reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055680, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10003321, 'VCR Dispute enable')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055681, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10003322, 'Issuer country')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055682, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1665, 'VCR Dispute Response Financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055683, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1666, 'VCR Dispute Financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055684, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1667, 'VCR Dispute Response Financial Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055685, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1668, 'VCR Dispute Financial Reversal')
/
update com_i18n c set c.text = 'Visa Fraud Monitoring Program' where c.id = 100000032826
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055738, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1308, 'Visa token bulk-file format')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055739, 'LANGENG', NULL, 'COM_FLEXIBLE_FIELD', 'LABEL', 10003328, 'Visa Bussines ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055741, 'LANGENG', NULL, 'COM_FLEXIBLE_FIELD', 'DESCRIPTION', 10003328, 'Visa BID - Represents the Business ID (BID) number for your organization, i.e. the issuer BID.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055735, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1482, 'Visa VDEP token file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055734, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001033, 'Visa VDEP token bulk file unloading')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055732, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007431, 'Bulk File for Visa Token Service')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055733, 'LANGENG', NULL, 'COM_DICTIONARY', 'DESCRIPTION', 10007431, 'VISA VDEP')
/
update com_i18n set text = 'Visa/Plus Retrieval request reason codes' where id in (100000046651)
/
update com_i18n set text = 'Visa/Plus Retrieval request reason codes' where id in (100000046658)
/
update com_i18n set text = 'Healthcare Auto-Sub Data Retrieval Request (U.S. Region only)' where id = 100000046652
/
update com_i18n set text = 'Fraud analysis request / Legal process or fraud analysis request (U.S. Region only)' where id = 100000046656
/
update com_i18n set text = 'Legal process request / Repeat request for copy (U.S. Region only)' where id = 100000046657
/
delete from com_i18n where id = 100000046654
/
update com_i18n set text = 'Visa/Plus Fee collection/Funds disbursement reason codes' where id in (100000136809)
/
update com_i18n set text = 'Visa/Plus Fee collection/Funds disbursement reason codes' where id in (100000136885)
/
update com_i18n set text = 'Telecommunications charges (telephone, fax, and cable)' where id = 100000136810
/
delete from com_i18n where id = 100000136815
/
update com_i18n set text = 'Recovery of Retrieval Request fee' where id = 100000136816
/
delete from com_i18n where id = 100000136817
/
update com_i18n set text = 'Arbitration/Compliance case decision or filing fee' where id = 100000136820
/
update com_i18n set text = 'Funds Disbursement' where id = 100000136822
/
update com_i18n set text = '"Cardholder Does Not Recognize Transaction" Chargeback handling fee (US Region only)' where id = 100000136823
/
delete from com_i18n where id = 100000136824
/
update com_i18n set text = 'Pre-Arbitration/Pre-Compliance Settlement funds disbursement' where id = 100000136825
/
delete from com_i18n where id = 100000051256
/
delete from com_i18n where id = 100000136826
/
delete from com_i18n where id = 100000051257
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056069, 'LANGENG', NULL, 'COM_LOV', 'NAME', 565, 'Visa/Plus Fee collection/Funds disbursement dispute module reason codes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056070, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007506, 'Plus Chargeback reason codes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056071, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007507, 'Shared Deposit, No Documentation Received for Deposit Return Item')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056072, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007508, 'Shared Deposit, Performed But Not Processed or Processed Incorrectly')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056073, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007509, 'Shared Deposit, Invalid Adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056074, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007510, 'Counterfeit Transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056075, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007511, 'Invalid or Unpostable Adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056076, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007512, 'Duplicate Processing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000056077, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007513, 'Non-Receipt of Cash at ATM')
/
update com_i18n set text = 'VISA BASEII clearing file uploading' where id = 100000021946
/
update com_i18n set text = 'Visa VDEP token bulk file uploading' where id = 100000055734
/
update com_i18n set text = 'VISA BINs downloading' where id = 100000027847
/
update com_i18n set text = 'VISA countries downloading' where id = 100000027849
/
update com_i18n set text = 'VISA MCCs downloading' where id = 100000027850
/
update com_i18n set text = 'VISA currencies downloading' where id = 100000027851
/
update com_i18n set text = 'VISA BASEII clearing file downloading' where id = 100000021948
/
update com_i18n set text = 'VISA Rejected Item Files downloading' where id = 100000050556
/
update com_i18n set text = 'VISA BASEII outgoing clearing' where id = 100000021946
/
update com_i18n set text = 'Visa VDEP token bulk file unloading' where id = 100000055734
/
update com_i18n set text = 'Loading Visa bin' where id = 100000027847
/
update com_i18n set text = 'Loading Visa country' where id = 100000027849
/
update com_i18n set text = 'Loading Visa mcc' where id = 100000027850
/
update com_i18n set text = 'Loading Visa currency' where id = 100000027851
/
update com_i18n set text = 'VISA BASEII incoming clearing' where id = 100000021948
/
update com_i18n set text = 'VISA Rejected Item Files loading' where id = 100000050556
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064414, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007669, 'Transaction voided by cardholder (online correction)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064416, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007670, 'Wrong amount due to ATM misdispense (online correction)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064418, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007671, 'Acquirer correction (“back-office” adjustment)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064419, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007672, 'Switch-generated adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064420, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007673, 'Prepaid load adjustment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064421, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007674, 'Approved transaction, previously reversed when no confirmation received from point of service, did complete')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064422, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007675, 'Credit adjustment, duplicate correction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064429, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007678, 'VISA SMS adjustments reason codes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064411, 'LANGENG', NULL, 'COM_LOV', 'NAME', 588, 'VISA SMS adjustments reason codes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064437, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007679, 'VISA SMS dispute message generation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064817, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007681, 'VISA SMS dispute messages to FE')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064823, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001060, 'Unload VISA SMS dispute messages to Front End')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064824, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1502, 'Visa SMS Dispute messages file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064723, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000188, 'Passenger Itinerary. Passenger Name')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064724, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000189, 'Passenger Itinerary. Departure Date (MMDDYY)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064725, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000190, 'Passenger Itinerary. Origination City/Airport Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064726, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000191, 'Passenger Itinerary. Trip Leg 1. Carrier Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064727, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000192, 'Passenger Itinerary. Trip Leg 1. Service Class')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064728, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000193, 'Passenger Itinerary. Trip Leg 1. Stop-Over Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064729, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000194, 'Passenger Itinerary. Trip Leg 1. Destination City/Airport Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064730, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000195, 'Passenger Itinerary. Trip Leg 2. Carrier Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064731, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000196, 'Passenger Itinerary. Trip Leg 2. Service Class')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064732, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000197, 'Passenger Itinerary. Trip Leg 2. Stop-Over Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064733, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000198, 'Passenger Itinerary. Trip Leg 2. Destination City/Airport Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064734, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000199, 'Passenger Itinerary. Trip Leg 3. Carrier Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064735, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000200, 'Passenger Itinerary. Trip Leg 3. Service Class')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064736, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000201, 'Passenger Itinerary. Trip Leg 3. Stop-Over Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064737, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000202, 'Passenger Itinerary. Trip Leg 3. Destination City/Airport Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064738, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000203, 'Passenger Itinerary. Trip Leg 4. Carrier Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064739, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000204, 'Passenger Itinerary. Trip Leg 4. Service Class')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064740, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000205, 'Passenger Itinerary. Trip Leg 4. Stop-Over Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064741, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000206, 'Passenger Itinerary. Trip Leg 4. Destination City/Airport Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064742, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000207, 'Passenger Itinerary. Travel Agency Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064743, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000208, 'Passenger Itinerary. Travel Agency Name')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064744, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000209, 'Passenger Itinerary. Restricted Ticket Indicator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064745, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000210, 'Passenger Itinerary. Fare Basis Code - Leg 1')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064746, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000211, 'Passenger Itinerary. Fare Basis Code - Leg 2')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064747, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000212, 'Passenger Itinerary. Fare Basis Code - Leg 3')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064748, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000213, 'Passenger Itinerary. Fare Basis Code - Leg 4')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064749, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000214, 'Passenger Itinerary. Computerized Reservation System')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064750, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000215, 'Passenger Itinerary. Flight Number - Leg 1')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064751, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000216, 'Passenger Itinerary. Flight Number - Leg 2')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064752, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000217, 'Passenger Itinerary. Flight Number - Leg 3')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064753, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000218, 'Passenger Itinerary. Flight Number - Leg 4')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064754, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000219, 'Passenger Itinerary. Credit Reason Indicator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000064755, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000220, 'Passenger Itinerary. Ticket Change Indicator')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000065271, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2424, 'Financial status advices')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000065273, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000554, 'View VISA financial status advices')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000065345, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1328, 'Loading Visa BIN file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000065324, 'LANGENG', NULL, 'CMN_STANDARD_VERSION', 'DESCRIPTION', 1051, '17.Q4 Mandatory changes.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000065335, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000222, 'Authorization source code')
/
update com_i18n set text = 'Recovered card handling fees or rewards and ATM BI acquiring direct fee returns' where id = 100000136814
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000148633, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003702, 'Send outgoing Visa clearing file to Institution')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000005826, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003703, 'Send outgoing Visa clearing file to Network')
/
update com_i18n set text = 'Send outgoing Visa fraud messages to Institution' where id = 100000148633
/
update com_i18n set text = 'Send outgoing Visa fraud messages to Network' where id = 100000005826
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006308, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003793, 'Register loading event')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006682, 'LANGENG', NULL, 'RPT_REPORT', 'LABEL', 10000220, 'Visa unmatched presentments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006683, 'LANGENG', NULL, 'RPT_PARAMETER', 'LABEL', 10003874, 'Institution')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006684, 'LANGENG', NULL, 'RPT_PARAMETER', 'LABEL', 10003875, 'Date start')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006685, 'LANGENG', NULL, 'RPT_PARAMETER', 'LABEL', 10003876, 'End date')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006686, 'LANGENG', NULL, 'RPT_TEMPLATE', 'LABEL', 10000324, 'Visa unmatched presentments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006941, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10006403, 'Too many Visa authorizations. Operation type [#1], Reference number [#2], Settlement date [#3], Message type [#4]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006843, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000235, 'Business format code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006848, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008059, 'Incorrect processing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006849, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008060, 'Account or credentials takeover')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006892, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008080, 'Dispute condition')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006899, 'LANGENG', NULL, 'COM_LOV', 'NAME', 625, 'Dispute condition')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006904, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008081, 'Dispute financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006916, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008082, 'EMV Liability Shift Counterfeit Fraud')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006918, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008084, 'EMV Liability Shift Non-Counterfeit Fraud')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006919, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008085, 'Other Fraud – Card-Present Environment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006920, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008086, 'Other Fraud – Card-Absent Environment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006921, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008087, 'Visa Fraud Monitoring Program')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006922, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008088, 'Card Recovery Bulletin')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006923, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008089, 'Declined Authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006924, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008090, 'No Authorization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006925, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008091, 'Late Presentment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006926, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008092, 'Incorrect Transaction Code')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006927, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008093, 'Incorrect Currency')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006928, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008094, 'Incorrect Account Number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006929, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008095, 'Incorrect Amount')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006930, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008096, 'Duplicate Processing/Paid by Other Means')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006931, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008097, 'Invalid Data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006932, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008098, 'Merchandise/Services Not Received')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006933, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008099, 'Cancelled Recurring Transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006934, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008100, 'Not as Described or Defective Merchandise/Services')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006935, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008101, 'Counterfeit Merchandise')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006936, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008102, 'Misrepresentation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006937, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008103, 'Credit Not Processed')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006938, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008104, 'Cancelled Merchandise/Services')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006939, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008105, 'Original Credit Transaction Not Accepted')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000006940, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008106, 'Non-Receipt of Cash or Load Transaction Value')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007040, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003914, 'Host Institution for Visa fraud messages')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007041, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10003915, 'Need modify Processing BIN for Visa fraud messages')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007218, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1130, 'VCR Dispute Response Financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007219, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1131, 'VCR Dispute Financial')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007220, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1132, 'VCR Dispute Response Financial Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007221, 'LANGENG', NULL, 'DSP_LIST_CONDITION', 'NAME', 1133, 'VCR Dispute Financial Reversal')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007437, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001090, 'Visa VSS report uploading')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007449, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008186, 'VSS message')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007479, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008187, 'VSS message')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007481, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008188, 'VISA interchange fee report file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007497, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1515, 'VISA interchange fee report file')
/
delete from com_i18n where id = 100000148633
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008244, 'LANGENG', NULL, 'ACM_SECTION', 'CAPTION', 2435, 'SMS Reports')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008246, 'LANGENG', NULL, 'ACM_PRIVILEGE', 'LABEL', 10000588, 'View VISA SMS reports')
/
delete from com_i18n where id = 100000008244
/
delete from com_i18n where id = 100000008246
/
-- VSAT - Visa VSS Amount Type
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008454, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008340, 'Visa VSS Amount Type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008456, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008341, 'Interchange')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008458, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008342, 'Reimbursement Fees')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008459, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008343, 'VISA Charges')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008460, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008344, 'Total')
/

insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008466, 'LANGENG', NULL, 'COM_LOV', 'NAME', 666, 'Visa VSS Amount Type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008467, 'LANGENG', NULL, 'COM_ARRAY_TYPE', 'LABEL', 1071, 'Visa VSS Amount type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008599, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10004121, 'Russian rouble settlement')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009556, 'LANGENG', NULL, 'CMN_PARAMETER', 'CAPTION', 10004267, 'Processing BIN for header')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009576, 'LANGENG', NULL, 'AUP_TAG', 'NAME', 10000258, 'Payment Account Reference')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000009660, 'LANGENG', NULL, 'CMN_STANDARD_VERSION', 'DESCRIPTION', 1090, 'Starting from 13 October 2018')
/
update com_i18n set text = 'Processing center''s BIN' where id = 100000009556
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000011712, 'LANGENG', NULL, 'CMN_PARAMETER', 'DESCRIPTION', 10004267, 'BIN of processing center via which the member is interaction with Visa. It is used for generate header of outgoing file from member which is not connected to Visa.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112964, 'LANGENG', NULL, 'SET_PARAMETER', 'CAPTION', 10004383, 'Participant VISA debt repayment program')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112979, 'LANGENG', NULL, 'RUL_MOD_PARAM', 'SHORT_DESCRIPTION', 10004385, 'VCR Dispute status')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113025, 'LANGENG', NULL, 'COM_ARRAY', 'LABEL', 10000108, 'VISA quarterly report card networks')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113026, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002558, 'VISA')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113225, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008535, 'Visa Money Transfer (VMT)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113248, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002603, 'OCredit')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113879, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008628, 'Visa AMMF service activation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113880, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008629, 'Visa AMMF service deactivation')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113881, 'LANGENG', NULL, 'PRD_SERVICE_TYPE', 'LABEL', 10004482, 'Visa AMMF service')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113959, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001153, 'Export Visa Acquirer Merchant Master File (AMMF)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113960, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1555, 'Visa Acquirer Merchant Master File (AMMF)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115185, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008642, 'Visa Acquirer Merchant Master File (AMMF)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115862, 'LANGENG', NULL, 'COM_ARRAY', 'LABEL', 10000115, 'VISA CEMEA quarterly report acquiring')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115863, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002604, 'Payments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115864, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002605, 'Account Funding Transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115865, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002606, 'Original Credits')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115866, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002607, 'ATM Cash Advances')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115867, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002608, 'Manual Cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115868, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002609, 'Cashback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115869, 'LANGENG', NULL, 'COM_ARRAY_CONVERSION', 'LABEL', 1023, 'VISA CEMEA quarterly acquiring')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115870, 'LANGENG', NULL, 'COM_ARRAY', 'LABEL', 10000116, 'VISA CEMEA quarterly report issuing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115871, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002610, 'Payments')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115872, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002611, 'Account Funding Transaction')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115873, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002612, 'Original Credits')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115874, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002613, 'ATM Cash Advances')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115875, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002614, 'Manual Cash')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115876, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002615, 'Cashback')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115877, 'LANGENG', NULL, 'COM_ARRAY_CONVERSION', 'LABEL', 1024, 'VISA CEMEA quarterly issuing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115940, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10008664, 'Visa VCF file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115942, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001155, 'Visa VCF file unloading')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000115946, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1556, 'Visa VCF outgoing file')
/
update com_i18n set text = 'Visa VCF file unloading (prototype)' where id = 100000115942
/
