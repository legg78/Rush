insert into net_member (id, seqnum, network_id, inst_id, participant_type, status, inactive_till) values (1, 1, 1002, 9001, NULL, 'HSST0001', NULL)
/
insert into net_member (id, seqnum, network_id, inst_id, participant_type, status, inactive_till) values (2, 1, 1003, 9002, NULL, 'HSST0001', NULL)
/
insert into net_member (id, seqnum, network_id, inst_id, participant_type, status, inactive_till) values (3, 1, 1001, 1001, NULL, 'HSST0001', NULL)
/
insert into net_member (id, seqnum, network_id, inst_id, participant_type, status, inactive_till, scale_id) values (5, 2, 1006, 9005, NULL, 'HSST0001', NULL, NULL)
/
insert into net_member (id, seqnum, network_id, inst_id, participant_type, status, inactive_till, scale_id) values (4, 1, 1005, 9004, NULL, NULL, NULL, NULL)
/
insert into net_member (id, seqnum, network_id, inst_id, participant_type, status, inactive_till, scale_id) values (1001, 1, 1003, 9006, NULL, NULL, NULL, NULL)
/
insert into net_member (id, seqnum, network_id, inst_id, participant_type, status, inactive_till, scale_id) values (1002, 1, 1004, 9003, NULL, NULL, NULL, NULL)
/
insert into net_member (id, seqnum, network_id, inst_id, participant_type, status, inactive_till, scale_id) values (1003, 1, 1002, 9010, NULL, NULL, NULL, NULL)
/
update net_member set status = 'HSST0001' where id = 1002
/
