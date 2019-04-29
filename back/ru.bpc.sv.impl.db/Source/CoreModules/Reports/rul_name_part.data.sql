insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000089, 1306, 10, 'BVTPCNST', 'NOTIF_INVOICE_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000090, 1306, 20, 'BVTPPRMT', 'INVOICE_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000091, 1306, 30, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000092, 1306, 40, 'BVTPPRMT', 'INST_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
update rul_name_part set transformation_type = 'TSFTOSQL', transformation_mask='to_number(:INVOICE_ID, ''FM000000000000000000.0000'')' where id = 10000090
/
update rul_name_part set transformation_type = 'TSFTOSQL', transformation_mask='to_number(:INST_ID, ''FM000000000000000000.0000'')' where id = 10000092
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000114, 1312, 10, 'BVTPCNST', 'REPORT_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000115, 1312, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'substr(:SYS_DATE,1,16)', NULL, NULL, NULL, NULL)
/
update rul_name_part set part_order = 40 where id = 10000115
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000116, 1312, 20, 'BVTPPRMT', 'INST_ID', 'TSFTOSQL', 'to_number(:INST_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000117, 1312, 30, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000118, 1312, 50, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000119, 1312, 60, 'BVTPPRMT', 'ENTITY_TYPE', 'TSFTOSQL', 'substr(:ENTITY_TYPE,5,4)', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000120, 1312, 70, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000121, 1312, 80, 'BVTPPRMT', 'OBJECT_ID', 'TSFTOSQL', 'to_number(:OBJECT_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000122, 1312, 90, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000123, 1312, 100, 'BVTPPRMT', 'EVENT_OBJECT_ID', 'TSFTOSQL', 'to_number(:EVENT_OBJECT_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000124, 1312, 110, 'BVTPCNST', '_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000125, 1312, 120, 'BVTPPRMT', 'SESSION_ID', 'TSFTOSQL', 'to_number(:SESSION_ID, ''FM000000000000000000.0000'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000151, 1312, 130, 'BVTPCNST', '.', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (10000149, 1312, 140, 'BVTPPRMT', 'REPORT_FORMAT', 'TSFTOSQL', 'decode(:REPORT_FORMAT,''RPTFTEXT'',''TXT'',''RPTFHTML'',''HTML'',''RPTFCSV'',''CSV'',''RPTFXLS'',''XLS'',''RPTFPDF'',''PDF'')', 5, NULL, NULL, NULL)
/
