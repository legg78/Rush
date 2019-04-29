insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (9, 1, 1016, '1442___', 100, 'MSGTCHBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (10, 1, 1016, '1240___', 100, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (11, 1, 1016, '1740700', 100, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (12, 1, 1016, '1740780', 100, 'MSGTCHBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (13, 1, 1016, '1740781', 100, 'MSGTREPR')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (14, 1, 1016, '1740782', 100, 'MSGTACBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (15, 1, 1016, '1740783', 100, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (16, 1, 1016, '1644603', 100, 'MSGTPRES')
/

update net_msg_type_map set network_msg_type = '1240200' where id = 10
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (19, 1, 1016, '1240205', 100, 'MSGTREPR')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (20, 1, 1016, '1240282', 100, 'MSGTREPR')
/
update net_msg_type_map set msg_type = 'MSGTRTRQ' where id = 16
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1004, 1, 1016, '_______1403', 101, 'MSGTPAMC')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1005, 1, 1016, '_______1404', 102, 'MSGTCMPL')
/
update net_msg_type_map set msg_type = 'MSGTPRES' where id = 1005
/
update net_msg_type_map set msg_type = 'MSGTPACC' where id = 1005
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1007, 1, 1016, '1644605', 100, 'MSGTRTRA')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1032, 1, 1016, '1442451', 90, 'MSGTACBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1033, 1, 1016, '1442454', 90, 'MSGTACBK')
/

