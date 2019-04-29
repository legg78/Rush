insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id, check_name) values (1278, 9999, 1, 'ENTTCUST', 22, 'PADTLEFT', '0', 'CHCKNCHK', NULL, NULL, NULL, NULL, 0)
/
insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id) values (1279, 1001, 1, 'ENTTACCT', 32, 'PADTLEFT', '0', 'CHCKNCHK', NULL, NULL, NULL, NULL)
/
insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id) values (1280, 1001, 1, 'ENTTCARD', NULL, 'PADTLEFT', '0', 'CHCKNCHK', NULL, NULL, NULL, NULL)
/
insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id) values (1281, 1001, 1, 'ENTTMRCH', 15, 'PADTLEFT', '0', 'CHCKNCHK', NULL, NULL, NULL, NULL)
/
insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id) values (1282, 1001, 1, 'ENTTTRMN', 8, 'PADTLEFT', '0', 'CHCKNCHK', NULL, NULL, NULL, NULL)
/
insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id) values (1283, 1001, 1, 'ENTTCRDH', 32, 'PADTLEFT', '0', 'CHCKNCHK', NULL, NULL, NULL, NULL)
/
insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id) values (1284, 1001, 1, 'ENTTCNTR', 32, 'PADTLEFT', '0', 'CHCKNCHK', NULL, NULL, NULL, NULL)
/


update rul_name_format set inst_id = 9999 where id = 1278
/
update rul_name_format set inst_id = 9999 where id = 1284
/
delete rul_name_format where id = 1280
/
insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id, check_name) values (1280, 1001, 1, 'ENTTCARD', 16, 'PADTRGHT', '0', 'CHCKLUHN', 1, 15, 16, 1, 0)
/
