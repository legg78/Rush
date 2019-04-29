insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000007, 5002, 10, 'BVTPCNST', 'BMED_ACCT_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000008, 5002, 20, 'BVTPPRMT', 'TIMESTAMP', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000009, 5003, 10, 'BVTPPRMT', 'UID_PREFIX', 'TSFTNOTR', NULL, 7, 'PADTLEFT', '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000010, 5003, 20, 'BVTPINDX', NULL, 'TSFTNOTR', NULL, 6, 'PADTLEFT', '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000011, 5003, 30, 'BVTPCNST', '0', 'TSFTNOTR', NULL, 1, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000012, 5004, 10, 'BVTPCNST', 'MED_CMO_FILE_EXTRACT_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000013, 5004, 20, 'BVTPINDX', NULL, 'TSFTNOTR', NULL, 3, 'PADTLEFT', '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000014, 5004, 30, 'BVTPCNST', '.txt', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000686, -5091, 30, 'BVTPCNST', '.out', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000685, -5091, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'TO_CHAR(TO_DATE(:SYS_DATE, get_date_format), ''DDD'')', 3, 'PADTLEFT', '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000684, -5091, 10, 'BVTPCNST', 'acc_pa', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000688, -5092, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'TO_CHAR(TO_DATE(:SYS_DATE, get_date_format), ''DDD'')', 3, 'PADTLEFT', '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000687, -5092, 10, 'BVTPCNST', 'MED_INDB_GATEWAY.', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000691, -5093, 30, 'BVTPCNST', '_new', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000690, -5093, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'TO_CHAR(TO_DATE(:SYS_DATE, get_date_format), ''DyDDMonYYYY'', ''NLS_DATE_LANGUAGE = AMERICAN'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000689, -5093, 10, 'BVTPCNST', 'in', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
