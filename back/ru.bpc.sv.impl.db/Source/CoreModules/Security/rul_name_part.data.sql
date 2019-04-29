insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1352, 1267, 10, 'BVTPPRMT', 'TRACKING_NUMBER', 'TSFTOSQL', 'TO_NUMBER(:TRACKING_NUMBER,''FM000000000000000000.0000'')', 6, 'PADTLEFT', '0')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1353, 1267, 20, 'BVTPCNST', '-', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1354, 1267, 30, 'BVTPPRMT', 'KEY_INDEX', 'TSFTOSQL', 'TO_CHAR(TO_NUMBER(:KEY_INDEX,''FM000000000000000000.0000''), RPAD(''FM'', LENGTH(TO_NUMBER(:KEY_INDEX,''FM000000000000000000.0000'')) + 2, ''X''))', 6, 'PADTLEFT', '0')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1355, 1268, 10, 'BVTPPRMT', 'TRACKING_NUMBER', 'TSFTOSQL', 'TO_NUMBER(:TRACKING_NUMBER,''FM000000000000000000.0000'')', 6, 'PADTLEFT', '0')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1356, 1268, 20, 'BVTPCNST', '-', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1357, 1268, 30, 'BVTPPRMT', 'KEY_INDEX', 'TSFTOSQL', 'TO_CHAR(TO_NUMBER(:KEY_INDEX,''FM000000000000000000.0000''), RPAD(''FM'', LENGTH(TO_NUMBER(:KEY_INDEX,''FM000000000000000000.0000'')) + 2, ''X''))', 6, 'PADTLEFT', '0')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1358, 1267, 40, 'BVTPCNST', '.sip', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1359, 1268, 40, 'BVTPCNST', '.hip', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1360, 1269, 10, 'BVTPCNST', 'CC', 'TSFTNOTR', '', null, '', '')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1361, 1269, 20, 'BVTPPRMT', 'TRACKING_NUMBER', 'TSFTOSQL', 'TO_NUMBER(:TRACKING_NUMBER,''FM000000000000000000.0000'')', 6, 'PADTLEFT', '0')
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1362, 1269, 30, 'BVTPCNST', '.inp', 'TSFTNOTR', '', null, '', '')
/
