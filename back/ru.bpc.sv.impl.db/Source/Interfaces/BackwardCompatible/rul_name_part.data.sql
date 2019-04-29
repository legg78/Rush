insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000067, 1302, 10, 'BVTPCNST', 'EVENT_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000068, 1302, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000069, 1302, 30, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000070, 1302, 40, 'BVTPPRMT', 'INST_ID', 'TSFTOSQL', 'to_number(:INST_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000071, 1302, 50, 'BVTPCNST', '.xml', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000072, 1303, 10, 'BVTPCNST', 'TURNOVER_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000073, 1303, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000074, 1303, 30, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000075, 1303, 40, 'BVTPPRMT', 'THREAD_NUMBER', 'TSFTOSQL', 'TO_NUMBER(:THREAD_NUMBER,''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000076, 1303, 50, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000077, 1303, 60, 'BVTPARRY', 'rul_api_name_transform_pkg.get_next_file', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000078, 1303, 70, 'BVTPCNST', '.xml', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
update rul_name_part set part_order=90 where id=10000078
/
update rul_name_part set part_order=80 where id=10000077
/
update rul_name_part set part_order=70 where id=10000076
/
update rul_name_part set part_order=60, transformation_mask='to_number(:THREAD_NUMBER,''FM000000000000000000.0000'')' where id=10000075
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000085, 1303, 40, 'BVTPPRMT', 'INST_ID', 'TSFTOSQL', 'to_number(:INST_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000086, 1303, 50, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000102, 1309, 10, 'BVTPCNST', 'OCG_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000103, 1309, 20, 'BVTPPRMT', 'SESSION_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000104, 1309, 30, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000105, 1309, 40, 'BVTPPRMT', 'CARD_TYPE_NAME', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000106, 1309, 50, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000107, 1309, 60, 'BVTPPRMT', 'PERSO_PRIORITY', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
update rul_name_part set part_order = 130 where id = 10000078
/
update rul_name_part set part_order = 100 where id = 10000077
/
update rul_name_part set part_order = 90 where id = 10000076
/
update rul_name_part set part_order = 80 where id = 10000075
/
update rul_name_part set part_order = 70 where id = 10000086
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000154, 1303, 50, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000155, 1303, 60, 'BVTPPRMT', 'SESSION_ID', 'TSFTOSQL', 'to_number(:SESSION_ID,''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
update  rul_name_part set base_value_type = 'BVTPPRMT', base_value = 'FILE_NUMBER', transformation_type = 'TSFTOSQL', transformation_mask = 'to_number(:FILE_NUMBER, ''FM000000000000000000.0000'')' where id = 10000077
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000158, 1303, 110, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000159, 1303, 120, 'BVTPPRMT', 'FILE_COUNT', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
delete from rul_name_part where id = 10000158
/
delete from rul_name_part where id = 10000159
/
update rul_name_part set part_order = 110 where id = 10000078
/
