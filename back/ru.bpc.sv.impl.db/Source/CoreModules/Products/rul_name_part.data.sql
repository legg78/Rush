insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000020, 1290, 10, 'BVTPPRMT', 'PRODUCT_ID', 'TSFTOSQL', 'to_number(:PRODUCT_ID, ''FM000000000000000000.0000'')', NULL, NULL, '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000025, 1291, 10, 'BVTPPRMT', 'SERVICE_ID', 'TSFTOSQL', 'to_number(:SERVICE_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000049, 1298, 10, 'BVTPCNST', 'PRODUCT_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000050, 1298, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000051, 1298, 30, 'BVTPCNST', '.xml', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000175, 1317, 10, 'BVTPPRMT', 'TIMESTAMP', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
