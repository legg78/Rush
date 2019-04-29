insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000001, 5001, 10, 'BVTPCNST', 'Card Holder Statement Report', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000002, 5001, 20, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000003, 5001, 30, 'BVTPPRMT', 'INST_ID', 'TSFTOSQL', 'to_number(:INST_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000004, 5001, 40, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000005, 5001, 50, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'substr(:SYS_DATE, 1, 8)', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000006, 5001, 100, 'BVTPCNST', '.pdf', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
