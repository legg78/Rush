-- Track 1
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1061, 1041, 10, 'BVTPPRMT', 'TRACK1_BEGIN', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1062, 1041, 20, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1063, 1041, 30, 'BVTPPRMT', 'TRACK1_SEPARATOR', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1064, 1041, 40, 'BVTPPRMT', 'CARDHOLDER_NAME', 'TSFTOSQL', 'substr(:CARDHOLDER_NAME, instr(:CARDHOLDER_NAME, '' '', 1, 1)+1) || ''/'' || substr(:CARDHOLDER_NAME, 1, instr(:CARDHOLDER_NAME, '' '', 1, 1)-1)', NULL, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1065, 1041, 50, 'BVTPPRMT', 'TRACK1_SEPARATOR', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1066, 1041, 60, 'BVTPPRMT', 'EXPIR_DATE', 'TSFTOSQL', 'substr(:EXPIR_DATE, 3, 2) || substr(:EXPIR_DATE, 5, 2)', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1072, 1041, 70, 'BVTPPRMT', 'SERVICE_CODE', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1073, 1041, 80, 'BVTPPRMT', 'PVK_INDEX', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1067, 1041, 90, 'BVTPPRMT', 'PVV', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1068, 1041, 100, 'BVTPCNST', '00000', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1443, 1041, 110, 'BVTPPRMT', 'CVV', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1444, 1041, 120, 'BVTPCNST', '00', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1445, 1041, 130, 'BVTPPRMT', 'CVV', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1446, 1041, 140, 'BVTPCNST', '000000', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1447, 1041, 150, 'BVTPPRMT', 'TRACK1_END', 'TSFTNOTR', '', null, '', '')
/

-- Track 2
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1069, 1042, 10, 'BVTPPRMT', 'TRACK2_BEGIN', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1070, 1042, 20, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1449, 1042, 25, 'BVTPPRMT', 'TRACK2_SEPARATOR', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1071, 1042, 30, 'BVTPPRMT', 'EXPIR_DATE', 'TSFTOSQL', 'substr(:EXPIR_DATE, 3, 2) || substr(:EXPIR_DATE, 5, 2)', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1074, 1042, 40, 'BVTPPRMT', 'SERVICE_CODE', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1448, 1042, 50, 'BVTPPRMT', 'PVK_INDEX', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1075, 1042, 60, 'BVTPPRMT', 'PVV', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1076, 1042, 70, 'BVTPCNST', '00000', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1077, 1042, 80, 'BVTPPRMT', 'CVV', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1078, 1042, 90, 'BVTPPRMT', 'TRACK2_END', 'TSFTNOTR', '', null, '', '')
/

-- Embossing Magnetic Stripe Card
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1080, 1043, 10, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTOSQL', 'substr(:CARD_NUMBER, 1, 4)||'' ''||substr(:CARD_NUMBER, 5, 6)||'' ''||substr(:CARD_NUMBER, 11)', NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1424, 1043, 15, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1425, 1043, 20, 'BVTPPRMT', 'EXPIR_DATE', 'TSFTOSQL', 'substr(:EXPIR_DATE, 3, 2) || substr(:EXPIR_DATE, 5, 2)', NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1426, 1043, 25, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1081, 1043, 30, 'BVTPPRMT', 'CARDHOLDER_NAME', 'TSFTNOTR', NULL, NULL, NULL, ' ')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1427, 1043, 35, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1082, 1043, 40, 'BVTPPRMT', 'COMPANY_NAME', 'TSFTNOTR', NULL, NULL, NULL, ' ')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1428, 1043, 45, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1429, 1043, 50, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTOSQL', 'substr(:CARD_NUMBER, 13, 4)', NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1430, 1043, 55, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1083, 1043, 60, 'BVTPPRMT', 'CVV2', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1431, 1043, 65, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1084, 1043, 70, 'BVTPPRMT', 'TRACK1', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1085, 1043, 80, 'BVTPPRMT', 'TRACK2', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/

-- Embossing for ICC
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1432, 1287, 10, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTOSQL', 'substr(:CARD_NUMBER, 1, 4)||'' ''||substr(:CARD_NUMBER, 5, 6)||'' ''||substr(:CARD_NUMBER, 11)', NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1433, 1287, 15, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1434, 1287, 20, 'BVTPPRMT', 'EXPIR_DATE', 'TSFTOSQL', 'substr(:EXPIR_DATE, 3, 2) || substr(:EXPIR_DATE, 5, 2)', NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1435, 1287, 25, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1436, 1287, 30, 'BVTPPRMT', 'CARDHOLDER_NAME', 'TSFTNOTR', NULL, 26, 'PADTRGHT', ' ')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1437, 1287, 35, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1438, 1287, 40, 'BVTPPRMT', 'COMPANY_NAME', 'TSFTNOTR', NULL, 26, 'PADTRGHT', ' ')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1439, 1287, 45, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1440, 1287, 50, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTOSQL', 'substr(:CARD_NUMBER, 13, 4)', NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1441, 1287, 55, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1442, 1287, 60, 'BVTPPRMT', 'CVV2', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/

-- Pin Mailer
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1142, 1124, 50, 'BVTPPRMT', 'PIN_BLOCK', 'TSFTNOTR', '', null, 'PADTRGHT', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1228, 1124, 20, 'BVTPPRMT', 'CARDHOLDER_NAME', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1229, 1124, 10, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTOSQL', 'substr(:CARD_NUMBER, 1, 4)||'' ''||substr(:CARD_NUMBER, 5, 6)||'' ''||substr(:CARD_NUMBER, 11)', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1230, 1124, 30, 'BVTPPRMT', 'COMPANY_NAME', 'TSFTNOTR', '', null, '', '')
/

-- Track 1 MC PayPass
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1363, 1270, 10, 'BVTPPRMT', 'TRACK1_BEGIN_CONTACTLESS', 'TSFTNOTR', 'B', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1364, 1270, 20, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1365, 1270, 30, 'BVTPPRMT', 'TRACK1_SEPARATOR', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1366, 1270, 40, 'BVTPPRMT', 'CARDHOLDER_NAME', 'TSFTOSQL', 'substr(:CARDHOLDER_NAME, instr(:CARDHOLDER_NAME, '' '', 1, 1)+1) || ''/'' || substr(:CARDHOLDER_NAME, 1, instr(:CARDHOLDER_NAME, '' '', 1, 1)-1)', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1367, 1270, 50, 'BVTPPRMT', 'TRACK1_SEPARATOR', 'TSFTNOTR', '', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1368, 1270, 60, 'BVTPPRMT', 'EXPIR_DATE', 'TSFTOSQL', 'substr(:EXPIR_DATE, 3, 2) || substr(:EXPIR_DATE, 5, 2)', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1369, 1270, 70, 'BVTPPRMT', 'SERVICE_CODE', 'TSFTOSQL', '201', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1370, 1270, 80, 'BVTPPRMT', 'SEQ_NUMBER', 'TSFTNOTR', '', 2, 'PADTLEFT', '0')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1371, 1270, 90, 'BVTPPRMT', 'ATC_PLACEHOLDER', 'TSFTOSQL', 'nvl(:ATC_PLACEHOLDER, ''000'')', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1372, 1270, 110, 'BVTPPRMT', 'CVC3_PLACEHOLDER', 'TSFTOSQL', 'nvl(:CVC3_PLACEHOLDER,''000'')', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1373, 1270, 100, 'BVTPPRMT', 'UN_PLACEHOLDER', 'TSFTOSQL', 'nvl(:UN_PLACEHOLDER,''000'')', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1383, 1270, 120, 'BVTPCNST', '0', 'TSFTNOTR', '', null, '', '')
/

-- Track 2 MC PayPass
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1374, 1271, 10, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTNOTR', '', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1375, 1271, 20, 'BVTPPRMT', 'TRACK2_SEPARATOR_CONTACTLESS', 'TSFTNOTR', 'D', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1376, 1271, 30, 'BVTPPRMT', 'EXPIR_DATE', 'TSFTOSQL', 'substr(:EXPIR_DATE, 3, 2) || substr(:EXPIR_DATE, 5, 2)', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1377, 1271, 40, 'BVTPPRMT', 'SERVICE_CODE', 'TSFTOSQL', '201', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1378, 1271, 50, 'BVTPPRMT', 'SEQ_NUMBER', 'TSFTNOTR', '', 2, 'PADTLEFT', '0')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1379, 1271, 60, 'BVTPPRMT', 'ATC_PLACEHOLDER', 'TSFTOSQL', 'nvl(:ATC_PLACEHOLDER, ''000'')', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1380, 1271, 70, 'BVTPPRMT', 'UN_PLACEHOLDER', 'TSFTOSQL', 'nvl(:UN_PLACEHOLDER,''000'')', null, '', '')
/                                                                                                                                                              
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1381, 1271, 80, 'BVTPPRMT', 'CVC3_PLACEHOLDER', 'TSFTOSQL', 'nvl(:CVC3_PLACEHOLDER,''000'')', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1382, 1271, 90, 'BVTPCNST', '0', 'TSFTNOTR', '', null, '', '')
/

-- Chip template
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1384, 1272, 10, 'BVTPPRMT', 'ROWS_NUMBER', 'TSFTOSQL', 'to_number(:ROWS_NUMBER,''FM000000000000000000.0000'')', 8, 'PADTLEFT', '0')
/                                                                                                                                                             
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1385, 1272, 20, 'BVTPCNST', '#', 'TSFTNOTR', '', null, '', '')
/                                                                                                                                                             
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1386, 1272, 30, 'BVTPPRMT', 'EMBOSSING_DATA', 'TSFTNOTR', '', null, '', '')
/                                                                                                                                                             
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1387, 1272, 40, 'BVTPCNST', '#', 'TSFTNOTR', '', null, '', '')
/                                                                                                                                                             
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1388, 1272, 50, 'BVTPPRMT', 'TRACK1_DATA', 'TSFTNOTR', '', null, '', '')
/                                                                                                                                                             
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1389, 1272, 60, 'BVTPCNST', '#', 'TSFTNOTR', '', null, '', '')
/                                                                                                                                                             
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1390, 1272, 70, 'BVTPPRMT', 'TRACK2_DATA', 'TSFTNOTR', '', null, '', '')
/                                                                                                                                                             
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1450, 1272, 80, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1391, 1272, 90, 'BVTPPRMT', 'CHIP_DATA', 'TSFTNOTR', '', null, '', '')
/

-- icc visa track 1
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1399, 1285, 10, 'BVTPPRMT', 'TRACK1_BEGIN', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1400, 1285, 20, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1401, 1285, 30, 'BVTPPRMT', 'TRACK1_SEPARATOR', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1402, 1285, 40, 'BVTPPRMT', 'CARDHOLDER_NAME', 'TSFTOSQL', 'upper(substr(:CARDHOLDER_NAME, instr(:CARDHOLDER_NAME, '' '', 1, 1)+1) || ''/'' || substr(:CARDHOLDER_NAME, 1, instr(:CARDHOLDER_NAME, '' '', 1, 1)-1))', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1403, 1285, 50, 'BVTPPRMT', 'TRACK1_SEPARATOR', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1404, 1285, 60, 'BVTPPRMT', 'EXPIR_DATE', 'TSFTOSQL', 'substr(:EXPIR_DATE, 3, 2) || substr(:EXPIR_DATE, 5, 2)', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1405, 1285, 70, 'BVTPPRMT', 'SERVICE_CODE', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1406, 1285, 80, 'BVTPPRMT', 'PVK_INDEX', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1407, 1285, 90, 'BVTPPRMT', 'PVV', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1408, 1285, 100, 'BVTPCNST', '99999', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1409, 1285, 110, 'BVTPCNST', '00', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1410, 1285, 120, 'BVTPPRMT', 'CVV', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1411, 1285, 130, 'BVTPCNST', '000000', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1412, 1285, 140, 'BVTPPRMT', 'TRACK1_END', 'TSFTNOTR', '', null, '', '')
/

-- icc visa track 2
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1413, 1286, 10, 'BVTPPRMT', 'TRACK2_BEGIN', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1414, 1286, 20, 'BVTPPRMT', 'CARD_NUMBER', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1415, 1286, 30, 'BVTPPRMT', 'TRACK2_SEPARATOR', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1416, 1286, 40, 'BVTPPRMT', 'EXPIR_DATE', 'TSFTOSQL', 'substr(:EXPIR_DATE, 3, 2) || substr(:EXPIR_DATE, 5, 2)', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1417, 1286, 50, 'BVTPPRMT', 'SERVICE_CODE', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1418, 1286, 60, 'BVTPPRMT', 'PVK_INDEX', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1419, 1286, 70, 'BVTPPRMT', 'PVV', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1420, 1286, 80, 'BVTPCNST', '99999', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1421, 1286, 90, 'BVTPPRMT', 'CVV', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1422, 1286, 100, 'BVTPPRMT', 'TRACK2_END', 'TSFTNOTR', '', null, '', '')
/

update rul_name_part set part_length = 4, pad_type = 'PADTLEFT', pad_string = '0' where id in (1067, 1075, 1407, 1419)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1454, 1285, 105, 'BVTPPRMT', 'CVV', 'TSFTNOTR', '', null, '', '')
/
update rul_name_part set base_value = '00000' where id = 1420
/
--TRACK1_BEGIN
update rul_name_part set transformation_type = 'TSFTOSQL', transformation_mask = '''%B''' where id in (1061, 1399)
/
--TRACK1_END
update rul_name_part set transformation_type = 'TSFTOSQL', transformation_mask = '''?''' where id in (1447, 1412)
/
--TRACK1_SEPARATOR
update rul_name_part set transformation_type = 'TSFTOSQL', transformation_mask = '''^''' where id in (1063, 1065, 1365, 1367, 1401, 1403)
/
--TRACK2_BEGIN
update rul_name_part set transformation_type = 'TSFTOSQL', transformation_mask = ''';''' where id in (1069, 1413)
/
--TRACK2_END
update rul_name_part set transformation_type = 'TSFTOSQL', transformation_mask = '''?''' where id in (1078, 1422)
/
--TRACK2_SEPARATOR
update rul_name_part set transformation_type = 'TSFTOSQL', transformation_mask = '''=''' where id in (1449, 1415)
/
--TRACK1_BEGIN_CONTACTLESS
update rul_name_part set base_value = 'TRACK1_BEGIN', transformation_type = 'TSFTOSQL', transformation_mask = '''B''' where id in (1363)
/
--TRACK2_SEPARATOR_CONTACTLESS
update rul_name_part set base_value = 'TRACK2_SEPARATOR', transformation_type = 'TSFTOSQL', transformation_mask = '''D''' where id in (1375)
/
delete from rul_name_part where id = 1230
/
update rul_name_part set transformation_mask = '''**** **** '' || substr(:CARD_NUMBER, -8, 4) || '' '' || substr(:CARD_NUMBER, -4)' where id = 1229
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000001, 1124, 60, 'BVTPPRMT', 'INST_NAME', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000002, 1124, 70, 'BVTPPRMT', 'AGENT_NAME', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000003, 1124, 80, 'BVTPCNST', 'Card', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000004, 1124, 90, 'BVTPPRMT', 'ID_TYPE', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000005, 1124, 100, 'BVTPPRMT', 'ID_NUMBER', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000006, 1124, 110, 'BVTPPRMT', 'CARD_TYPE_NAME', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
update rul_name_part set transformation_mask = 'substr(:CARD_NUMBER, 1, 4)||'' ''||substr(:CARD_NUMBER, 5, 4)||'' ''||substr(:CARD_NUMBER, 9, 4)||'' ''||substr(:CARD_NUMBER, 13)' where id in (1080, 1432)
/
update rul_name_part set transformation_mask = 'substr(:EXPIR_DATE, 5, 2) || ''/'' || substr(:EXPIR_DATE, 3, 2)' where id in (1425, 1434)
/
update rul_name_part set part_length = 26, pad_type = 'PADTRGHT', pad_string = ' ' where id in (1081, 1082)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000007, 1043, 5, 'BVTPPRMT', 'ROWS_NUMBER', 'TSFTOSQL', 'to_number(:ROWS_NUMBER,''FM000000000000000000.0000'')', 8, 'PADTLEFT', '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000008, 1043, 6, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000009, 1043, 75, 'BVTPCNST', '#', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
update rul_name_part set base_value_type = 'BVTPPRMT', base_value = 'CARD_LABEL' where id = 10000003
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000018, 1272, 100, 'BVTPCNST', 'NEW_LINE', 'TSFTOSQL', 'CHR(13)||CHR(10)', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000019, 1043, 100, 'BVTPCNST', 'NEW_LINE', 'TSFTOSQL', 'CHR(13)||CHR(10)', NULL, NULL, NULL, NULL)
/
update rul_name_part set base_value_type = 'BVTPPRMT', base_value = 'END_OF_RECORD' where id in (10000018, 10000019)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000026, 1287, 100, 'BVTPPRMT', 'END_OF_RECORD', 'TSFTOSQL', 'CHR(13)||CHR(10)', NULL, NULL, NULL, NULL)
/
