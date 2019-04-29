insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000010, 1288, 1, 'BVTPCNST', 'VO_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000011, 1288, 2, 'BVTPPRMT', 'SYS_DATE', 'TSFTNOTR', NULL, NULL, NULL, NULL, 0)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000012, 1288, 3, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000013, 1288, 4, 'BVTPPRMT', 'INST_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000014, 1288, 5, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000015, 1288, 6, 'BVTPPRMT', 'KEY_INDEX', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
update rul_name_part set transformation_type = 'TSFTOSQL', transformation_mask = 'to_number(:INST_ID, ''FM000000000000000000.0000'')' where id = 10000013
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000097, 1308, 10, 'BVTPCNST', 'TOKEN_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000098, 1308, 20, 'BVTPPRMT', 'INST_ID', 'TSFTOSQL', 'vis_prc_vdep_pkg.get_bid(to_number(:INST_ID, ''FM000000000000000000.0000''))', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000099, 1308, 30, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000100, 1308, 40, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'substr(:SYS_DATE, 1, 12)', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000101, 1308, 99, 'BVTPCNST', '.csv', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
