insert into net_member (id, seqnum, network_id, inst_id, participant_type, status, inactive_till, scale_id) values (1004, 1, 1010, 9011, NULL, NULL, NULL, NULL)
/
update net_member set status='HSST0001' where id=1004
/
insert into net_member (id, seqnum, network_id, inst_id, participant_type, status, inactive_till, scale_id) values (1011, 1, 1010, 1001, NULL, 'HSST0001', NULL, NULL)
/
