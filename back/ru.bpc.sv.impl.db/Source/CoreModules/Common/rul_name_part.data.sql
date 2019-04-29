insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000030, 1293, 10, 'BVTPPRMT', 'COUNTRY', 'TSFTOSQL', 'NVL2(:COUNTRY, :COUNTRY || '', '', '''')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000031, 1293, 20, 'BVTPPRMT', 'POSTAL_CODE', 'TSFTOSQL', 'NVL2(:POSTAL_CODE, :POSTAL_CODE || '', '', '''')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000032, 1293, 30, 'BVTPPRMT', 'REGION_CODE', 'TSFTOSQL', 'NVL2(:REGION_CODE, :REGION_CODE || '', '', '''')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000033, 1293, 40, 'BVTPPRMT', 'REGION', 'TSFTOSQL', 'NVL2(:REGION, :REGION || '', '', '''')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000034, 1293, 50, 'BVTPPRMT', 'CITY', 'TSFTOSQL', 'NVL2(:CITY, :CITY || '', '', '''')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000035, 1293, 70, 'BVTPPRMT', 'HOUSE', 'TSFTOSQL', 'NVL2(:HOUSE, :HOUSE || '', '', '''')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000036, 1293, 80, 'BVTPPRMT', 'APARTMENT', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000037, 1293, 60, 'BVTPPRMT', 'STREET', 'TSFTOSQL', 'NVL2(:STREET, :STREET || '', '', '''')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000041, 1296, 10, 'BVTPCNST', 'RATE_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000042, 1296, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000043, 1296, 30, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000044, 1296, 40, 'BVTPPRMT', 'INST_ID', 'TSFTOSQL', 'to_number(:INST_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000045, 1296, 50, 'BVTPCNST', '.xml', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000052, 1299, 10, 'BVTPCNST', 'MERCHANT_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000053, 1299, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000054, 1299, 30, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000055, 1299, 40, 'BVTPPRMT', 'INST_ID', 'TSFTOSQL', 'to_number(:INST_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000056, 1299, 50, 'BVTPCNST', '.xml', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000057, 1300, 10, 'BVTPCNST', 'TERMINAL_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000058, 1300, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000059, 1300, 30, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000060, 1300, 40, 'BVTPPRMT', 'INST_ID', 'TSFTOSQL', 'to_number(:INST_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000061, 1300, 50, 'BVTPCNST', '.xml', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000081, 1300, 23, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000082, 1300, 27, 'BVTPPRMT', 'THREAD_NUMBER', 'TSFTOSQL', 'to_number(:THREAD_NUMBER,''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
