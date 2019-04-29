insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000027, 1292, 10, 'BVTPPRMT', 'FILE_PURPOSE', 'TSFTNOTR', NULL, 2, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000028, 1292, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'to_char(:SYS_DATE, ''YMMDD'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000029, 1292, 30, 'BVTPPRMT', 'FILE_NUMBER', 'TSFTNOTR', NULL, 1, NULL, NULL, NULL)
/
update rul_name_part set base_value_type = 'BVTPCNST', base_value = 'SI', part_length = null where id = 10000027
/
update rul_name_part set transformation_mask = 'substr(:SYS_DATE, 4, 5)' where id = 10000028
/
update rul_name_part set part_length = null where id = 10000029
/
