insert into fcl_limit_type (id, seqnum, limit_type, entity_type, cycle_type, is_internal, posting_method, counter_algorithm) values (-5003, 1, 'LMTP0401', NULL, NULL, 1, NULL, NULL)
/
insert into fcl_limit_type (id, seqnum, limit_type, entity_type, cycle_type, is_internal, posting_method, counter_algorithm) values (-5004, 1, 'LMTP5402', NULL, NULL, 1, NULL, NULL)
/
update fcl_limit_type set limit_type = 'LMTP5401' where id = -5003
/
delete from fcl_limit_type where id = -5003
/
