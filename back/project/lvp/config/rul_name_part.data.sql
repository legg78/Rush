insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000015, 5005, 10, 'BVTPCNST', 'Cards inventory by branches_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000016, 5005, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'substr(:SYS_DATE,1,16)', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (50000017, 5005, 30, 'BVTPCNST', '.xslx', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
update rul_name_part set base_value='.xls' where id = 50000017
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000678, -5089, 30, 'BVTPCNST', '.xls', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000677, -5089, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'substr(:SYS_DATE,1,16)', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000676, -5089, 10, 'BVTPCNST', 'Report_Recon_NAPAS_BNV', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000675, -5088, 30, 'BVTPCNST', '.xls', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000674, -5088, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'substr(:SYS_DATE,1,16)', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000673, -5088, 10, 'BVTPCNST', 'Report_Recon_NAPAS_SV', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000707, -5097, 50, 'BVTPCNST', '_1_SL_SWC.dat', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000705, -5097, 40, 'BVTPPRMT', 'ACQ_BIN', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000704, -5097, 20, 'BVTPCNST', '_BNB_BBB_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000701, -5097, 10, 'BVTPPRMT', 'REPORT_DATE', 'TSFTOSQL', 'TO_CHAR(TO_DATE(:REPORT_DATE, get_date_format), ''MMDDYY'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000708, -5096, 50, 'BVTPCNST', '_1_SL_SWC.dat', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000706, -5096, 40, 'BVTPPRMT', 'ACQ_BIN', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000703, -5096, 20, 'BVTPCNST', '_ACQ_BBB_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000702, -5096, 10, 'BVTPPRMT', 'REPORT_DATE', 'TSFTOSQL', 'TO_CHAR(TO_DATE(:REPORT_DATE, get_date_format), ''MMDDYY'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000700, -5095, 50, 'BVTPCNST', '_1_SL_SWC.dat', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000699, -5095, 40, 'BVTPPRMT', 'ACQ_BIN', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000697, -5095, 20, 'BVTPCNST', '_ISS_BBB_', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000696, -5095, 10, 'BVTPPRMT', 'REPORT_DATE', 'TSFTOSQL', 'TO_CHAR(TO_DATE(:REPORT_DATE, get_date_format), ''MMDDYY'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000720, -5102, 30, 'BVTPCNST', '_new', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000719, -5102, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'TO_CHAR(TO_DATE(:SYS_DATE, get_date_format), ''DyDDMonYYYY'', ''NLS_DATE_LANGUAGE = AMERICAN'')', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000718, -5102, 10, 'BVTPCNST', 'in', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000717, -5101, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'TO_CHAR(TO_DATE(:SYS_DATE, get_date_format), ''DDD'')', 3, 'PADTLEFT', '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000716, -5101, 10, 'BVTPCNST', 'MED_INDB_GATEWAY.', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000715, -5100, 30, 'BVTPCNST', '.out', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000714, -5100, 20, 'BVTPPRMT', 'SYS_DATE', 'TSFTOSQL', 'TO_CHAR(TO_DATE(:SYS_DATE, get_date_format), ''DDD'')', 3, 'PADTLEFT', '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (-50000713, -5100, 10, 'BVTPCNST', 'acc_pa', 'TSFTNOTR', NULL, NULL, NULL, NULL, NULL)
/
delete from rul_name_part where id = -50000673
/
delete from rul_name_part where id = -50000674
/
delete from rul_name_part where id = -50000675
/
delete from rul_name_part where id = -50000676
/
delete from rul_name_part where id = -50000677
/
delete from rul_name_part where id = -50000678
/
