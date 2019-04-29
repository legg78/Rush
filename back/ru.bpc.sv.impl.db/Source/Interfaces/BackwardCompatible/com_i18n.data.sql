insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030650, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000030, 'Uploading entrys in OBI format')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030652, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1341, 'OBI file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030666, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000031, 'Loading payments to / withdrawals from account')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030668, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1342, 'IBI file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030669, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1343, 'Rejected IBI file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030701, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000032, 'Export cards status in format OSL')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030703, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1344, 'OSL file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030716, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10002017, 'Rate type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030719, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000037, 'Load currency rate in TLV format')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000030723, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1345, 'Currency rates')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000031430, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10002115, 'Transaction Type')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045637, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011474, 'R_IBI_FILE_RAW_LENGTH_INCORRECT[#1][#2]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045658, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011492, 'R_IBI_FILE_REJECT_REASON_INCORRECT')
/
delete com_i18n where id = 100000045661
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045661, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011495, 'OCP_FILE_RAW_LENGTH_INCORRECT')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000045687, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10011522, 'IBI_FILE_RAW_LENGTH_INCORRECT')
/
update com_i18n set text = 'Invalid length line in file R-IBI. Row_length [#1], row [#2]' where id = 100000045637
/
update com_i18n set text = 'The reason for rejection is incorrect' where id = 100000045658
/
update com_i18n set text = 'Invalid length line in file OCP.' where id = 100000045661
/
update com_i18n set text = 'Invalid length line in file IBI.' where id = 100000045687
/
update com_i18n set text = 'Operations unloading (OBI format)' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000030 and lang = 'LANGENG'
/
update com_i18n set text = 'Operations loading (IBI format)' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000031 and lang = 'LANGENG'
/
update com_i18n set text = 'Card statuses unloading (OSL format)' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000032 and lang = 'LANGENG'
/
update com_i18n set text = 'Currency rates loading (TLV format)' where table_name = 'PRC_PROCESS' and column_name = 'NAME' and object_id = 10000037 and lang = 'LANGENG'
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137069, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005794, 'BER-TLV file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137067, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000886, 'Unloading cards in CardGen')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137070, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1384, 'Unloading cards in CardGen')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046673, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005799, 'Bridge File')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046671, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000887, 'Load cards from CardGen')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000046672, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1385, 'CardGen file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137063, 'LANGENG', NULL, 'COM_ARRAY_TYPE', 'LABEL', 1014, 'Card types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137065, 'LANGENG', NULL, 'COM_ARRAY_TYPE', 'LABEL', 1015, 'Card generator card types')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047143, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000891, 'Unloading merchants')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047145, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1389, 'File of merchants')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047151, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000892, 'Unloading terminals')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047153, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1390, 'File of terminals')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047146, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005850, 'Merchants')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000047148, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10005851, 'Terminals')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000048250, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000899, 'Accounts turnovers unloading(DBAL)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000048252, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1395, 'Turnover on accounts')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049463, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000903, 'Unload events')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049465, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1399, 'Events')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137169, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006315, 'Events file')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049770, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10006356, 'Update sensitive data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000049912, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10007011, 'Cardholders name is too long [#1]. Maximum 22 symbols.')
/
delete from com_i18n where id in (100000137063,100000137065)
/
update com_i18n set text = 'Events unloading' where id = 100000049463
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051274, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000947, 'Unload events')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051314, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1302, 'Event XML file format')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051534, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10002965, 'Export without address')
/
update com_i18n set text = 'Length [#2] of the cardholder''s name [#1] is too long, it exceeds maximum value [#3]' where id = 100000049912
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051633, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1303, 'Turnover XML file format')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051654, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10002996, 'Unload accounts')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051680, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10000951, 'Rejected accounts turnovers processing (reject DBAL)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051690, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009584, 'Length [#2] of the cardholder''s name [#1] is too short, it exceeds minimum value [#3]')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051691, 'LANGENG', NULL, 'COM_LABEL', 'NAME', 10009585, 'Cardholder name [#1] is started with space symbol')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051692, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003001, 'Check cardholder name')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000051693, 'LANGENG', NULL, 'PRC_PARAMETER', 'DESCRIPTION', 10003001, 'Check cardholder name according to the ISO 7813:2006.')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137460, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1418, 'Reject accounts')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000137461, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1419, 'Reject card numbers')
/
update com_i18n set text = 'Accounts turnovers unloading (DBAL)' where id = 100000048250
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052159, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003039, 'Include services')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052783, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003086, 'The number of cards')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000052784, 'LANGENG', NULL, 'PRC_PARAMETER', 'DESCRIPTION', 10003086, 'The number of cards in the batch')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054319, 'LANGENG', NULL, 'COM_ARRAY_TYPE', 'LABEL', 1044, 'Versions of the fraud monitoring specification')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054320, 'LANGENG', NULL, 'COM_ARRAY', 'LABEL', 10000052, 'Versions of the fraud monitoring specification')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054321, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002151, 'Version 1.0')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054322, 'LANGENG', NULL, 'COM_ARRAY_ELEMENT', 'LABEL', 10002152, 'Version 1.1')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054323, 'LANGENG', NULL, 'COM_LOV', 'NAME', 517, 'Fraud monitoring versions')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054324, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003140, 'Versions of the fraud monitoring specification')
/
delete com_i18n where table_name = 'PRC_PROCESS' and object_id = 10001010
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054325, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001010, 'Fraud monitoring: unloading cards data')
/
delete com_i18n where table_name = 'PRC_PROCESS' and object_id = 10001011
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054327, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001011, 'Fraud monitoring: unloading merchants data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054329, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001012, 'Fraud monitoring: unloading termials data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054331, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001013, 'Fraud monitoring: unloading clearing data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054333, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001014, 'Fraud monitoring: unloading currency rate data')
/
delete com_i18n where table_name = 'PRC_FILE' and object_id = 1455
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054326, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1455, 'Fraud monitoring: output cards data')
/
delete com_i18n where table_name = 'PRC_FILE' and object_id = 1456
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054328, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1456, 'Fraud monitoring: output merchants data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054330, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1457, 'Fraud monitoring: output terminals dsts')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054332, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1458, 'Fraud monitoring: output clearing data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054334, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1459, 'Fraud monitoring: output currency rate data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054441, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003143, 'Unload notes')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054722, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007238, 'Rejected merchant numbers')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054723, 'LANGENG', NULL, 'COM_DICTIONARY', 'NAME', 10007239, 'Rejected terminal numbers')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054724, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001021, 'Rejected merchants processing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054725, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001022, 'Rejected terminals processing')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054726, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1471, 'Rejected merchant numbers')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054727, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1472, 'Rejected terminal numbers')
/
update com_i18n set text = 'Fraud monitoring: unloading terminals data' where id = 100000054329
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054769, 'LANGENG', NULL, 'RUL_MOD_SCALE', 'NAME', 1019, 'Event''s subscriptions parametrization')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054770, 'LANGENG', NULL, 'RUL_MOD', 'NAME', 1623, 'Payment')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054847, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1478, 'Reject merchants')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000054848, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1479, 'Reject terminals')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055581, 'LANGENG', NULL, 'RUL_PROC', 'NAME', 1646, 'Add transmission data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000055582, 'LANGENG', NULL, 'RUL_RULE_SET', 'NAME', 1011, 'Add transmission data')
/
update com_i18n set text = 'Operations uploading (OBI format)' where id = 100000030650
/
update com_i18n set text = 'Card statuses uploading (OSL format)' where id = 100000030701
/
update com_i18n set text = 'Uploading cards in CardGen' where id = 100000137067
/
update com_i18n set text = 'Uploading merchants' where id = 100000047143
/
update com_i18n set text = 'Uploading terminals' where id = 100000047151
/
update com_i18n set text = 'Accounts turnovers uploading (DBAL)' where id = 100000048250
/
update com_i18n set text = 'Events uploading' where id = 100000049463
/
update com_i18n set text = 'Upload events' where id = 100000051274
/
update com_i18n set text = 'Fraud monitoring: uploading cards data' where id = 100000054325
/
update com_i18n set text = 'Fraud monitoring: uploading merchants data' where id = 100000054327
/
update com_i18n set text = 'Fraud monitoring: uploading terminals data' where id = 100000054329
/
update com_i18n set text = 'Fraud monitoring: uploading clearing data' where id = 100000054331
/
update com_i18n set text = 'Fraud monitoring: uploading currency rate data' where id = 100000054333
/
update com_i18n set text = 'Operations downloading (IBI format)' where id = 100000030666
/
update com_i18n set text = 'Currency rates downloading (TLV format)' where id = 100000030719
/
update com_i18n set text = 'Uploading entries in OBI format' where id = 100000030650
/
update com_i18n set text = 'Export cards status in format OSL' where id = 100000030701
/
update com_i18n set text = 'Unloading cards in CardGen' where id = 100000137067
/
update com_i18n set text = 'Unloading merchants' where id = 100000047143
/
update com_i18n set text = 'Unloading terminals' where id = 100000047151
/
update com_i18n set text = 'Accounts turnovers unloading (DBAL)' where id = 100000048250
/
update com_i18n set text = 'Events unloading' where id = 100000049463
/
update com_i18n set text = 'Unload events' where id = 100000051274
/
update com_i18n set text = 'Fraud monitoring: unloading cards data' where id = 100000054325
/
update com_i18n set text = 'Fraud monitoring: unloading merchants data' where id = 100000054327
/
update com_i18n set text = 'Fraud monitoring: unloading terminals data' where id = 100000054329
/
update com_i18n set text = 'Fraud monitoring: unloading clearing data' where id = 100000054331
/
update com_i18n set text = 'Fraud monitoring: unloading currency rate data' where id = 100000054333
/
update com_i18n set text = 'Loading payments to / withdrawals from account' where id = 100000030666
/
update com_i18n set text = 'Load currency rate in TLV format' where id = 100000030719
/
delete com_i18n where id = 100000054320
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000065304, 'LANGENG', NULL, 'RUL_NAME_FORMAT', 'LABEL', 1309, 'CardGen OCG file format')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000065444, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003650, 'Include flexible fields')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000148699, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003740, 'Column name of account number')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000148706, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001075, 'Accounts processing by event')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000148707, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1509, 'CSV-file which consist account numbers')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007127, 'LANGENG', NULL, 'CMN_STANDARD', 'LABEL', 1044, 'OCG Cardgen')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007182, 'LANGENG', NULL, 'COM_LOV', 'NAME', 630, 'OCG file version')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007183, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003934, 'OCG file version')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000007600, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10003983, 'Unload payments')
/
update com_i18n set text = 'Export cards numbers into CBS' where id = 100000136691
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008686, 'LANGENG', NULL, 'COM_ARRAY_TYPE', 'LABEL', 1072, 'Account types that are supported in CBS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000008683, 'LANGENG', NULL, 'COM_ARRAY', 'LABEL', 10000096, 'Account types that are supported in CBS')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000011830, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10004277, 'Unload acquiring accounts')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000011918, 'LANGENG', NULL, 'PRC_PROCESS', 'NAME', 10001126, 'Merchant accounts unloading (mVisa/MPQR DBAL)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000011919, 'LANGENG', NULL, 'PRC_PROCESS', 'DESCRIPTION', 10001126, 'mVisa/MPQR merchant accounts unloading (mVisa/MPQR DBAL)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000011920, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1535, 'Merchant accounts unloading')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000011921, 'LANGENG', NULL, 'PRC_FILE', 'DESCRIPTION', 1535, 'Merchant accounts unloading (mVisa/MPQR DBAL)')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000011922, 'LANGENG', NULL, 'PRC_FILE', 'NAME', 1536, 'Reject accounts')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112407, 'LANGENG', NULL, 'COM_LOV', 'NAME', 686, 'Issuing flow for Batch Card Personalization Process')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112414, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10004302, 'Flow ID')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000112417, 'LANGENG', NULL, 'PRC_PROCESS', 'DESCRIPTION', 10000033, 'OBSOLETE')
/
update com_i18n set text = 'Include notes' where id = 100000054441
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113286, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10004407, 'Include Visa clearing data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113287, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10004408, 'Include MasterCard clearing data')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113288, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10004409, 'Include block of payment orders')
/
insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values (100000113289, 'LANGENG', NULL, 'PRC_PARAMETER', 'LABEL', 10004410, 'Include block of additional amounts')
/
