insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1393, 1278, 10, 'BVTPPRMT', 'CUSTOMER_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1392, 1279, 10, 'BVTPPRMT', 'ACCOUNT_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1394, 1280, 10, 'BVTPPRMT', 'CARD_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1395, 1281, 10, 'BVTPPRMT', 'MERCHANT_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1396, 1282, 10, 'BVTPPRMT', 'TERMINAL_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1397, 1283, 10, 'BVTPPRMT', 'CARDHOLDER_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string) values (1398, 1284, NULL, 'BVTPPRMT', 'CONTRACT_ID', 'TSFTNOTR', NULL, NULL, NULL, NULL)
/
delete rul_name_part where id = 1394
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (1451, 1280, 10, 'BVTPPRMT', 'BIN', 'TSFTNOTR', NULL, 6, 'PADTRGHT', '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (1452, 1280, 20, 'BVTPINDX', NULL, 'TSFTNOTR', NULL, 9, 'PADTRGHT', '0', NULL)
/
insert into rul_name_part (id, format_id, part_order, base_value_type, base_value, transformation_type, transformation_mask, part_length, pad_type, pad_string, check_part) values (1453, 1280, 30, 'BVTPCNST', '0', 'TSFTNOTR', NULL, 1, NULL, NULL, NULL)
/
update rul_name_part set pad_type = 'PADTLEFT' where id = 1451
/
update rul_name_part set pad_type = 'PADTLEFT' where id = 1452
/
update rul_name_part set check_part = 1 where id = 1451
/