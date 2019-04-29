insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000062, 1301, 10, 'BVTPCNST', 'CARD_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000063, 1301, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000064, 1301, 30, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000065, 1301, 40, 'BVTPPRMT', 'INST_ID', 'TSFTOSQL', 'to_number(:INST_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000066, 1301, 50, 'BVTPCNST', '.xml', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000079, 1301, 44, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000080, 1301, 45, 'BVTPARRY', 'rul_api_name_transform_pkg.get_next_file', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
update rul_name_part set part_order=90 where id=10000066
/
update rul_name_part set part_order=80 where id=10000080
/
update rul_name_part set part_order=50 where id=10000079
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000083, 1301, 60, 'BVTPPRMT', 'THREAD_NUMBER', 'TSFTOSQL', 'to_number(:THREAD_NUMBER,''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000084, 1301, 70, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000088, 1305, 10, 'BVTPPRMT', 'CARD_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
update rul_name_part set transformation_type = 'TSFTOSQL', transformation_mask = 'substr(:CARD_ID, 1, decode (instr(:CARD_ID, ''.''), 0, 4000, instr(:CARD_ID, ''.'') - 1))' where id = 10000088
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000135, 1314, 10, 'BVTPPRMT', 'NAME_VALUE', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000136, 1314, 20, 'BVTPPRMT', 'APPLICATION_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000137, 1314, 30, 'BVTPPRMT', 'SEQ_NUMBER', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
update rul_name_part set part_order = 130 where id = 10000066
/
update rul_name_part set part_order = 100 where id = 10000080
/
update rul_name_part set part_order = 90 where id = 10000084
/
update rul_name_part set part_order = 80 where id = 10000083
/
update rul_name_part set part_order = 70 where id = 10000079
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000152, 1301, 50, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000153, 1301, 60, 'BVTPPRMT', 'SESSION_ID', 'TSFTOSQL', 'to_number(:SESSION_ID,''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
update  rul_name_part set base_value_type = 'BVTPPRMT', base_value = 'FILE_NUMBER', transformation_type = 'TSFTOSQL', transformation_mask = 'to_number(:FILE_NUMBER, ''FM000000000000000000.0000'')' where id = 10000080
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000156, 1301, 110, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000157, 1301, 120, 'BVTPPRMT', 'FILE_COUNT', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
delete from rul_name_part where id = 10000156
/
delete from rul_name_part where id = 10000157
/
update rul_name_part set part_order = 110 where id = 10000066
/
