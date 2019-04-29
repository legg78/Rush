insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id, check_name) values (-5120, 1001, 1, 'ENTTFILE', NULL, NULL, NULL, 'CHCKNCHK', NULL, NULL, NULL, NULL, 0)
/
insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id, check_name) values (-5121, 1001, 1, 'ENTTFILE', NULL, NULL, NULL, 'CHCKNCHK', NULL, NULL, NULL, NULL, 0)
/
insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id, check_name) values (-5122, 9999, 1, 'ENTTFILE', NULL, NULL, NULL, 'CHCKNCHK', NULL, NULL, NULL, NULL, 0)
/
update rul_name_format set inst_id = 9999 where id in (-5120, -5121)
/
insert into rul_name_format (id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm, check_base_position, check_base_length, check_position, index_range_id, check_name) values (-5123, 9999, 1, 'ENTTFILE', NULL, NULL, NULL, 'CHCKNCHK', NULL, NULL, NULL, NULL, 0)
/
