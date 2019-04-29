insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1, 1, 1008, '10', 100, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (2, 1, 1008, '12', 100, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (3, 1, 1008, '11', 100, 'MSGTCHBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (4, 1, 1008, '13', 100, 'MSGTCHBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (5, 1, 1008, '20', 100, 'MSGTREPR')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (6, 1, 1008, '22', 100, 'MSGTREPR')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (7, 1, 1008, '21', 100, 'MSGTACBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (8, 1, 1008, '23', 100, 'MSGTACBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (17, 1, 1008, '110', 10, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (18, 1, 1008, '120', 10, 'MSGTPRES')
/
update net_msg_type_map set network_msg_type = network_msg_type || '_' where id in (1,2,3,4,5,6,7,8)
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1003, 1, 1008, '15_', 110, 'MSGTRTRQ')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1006, 1, 1008, '140', 20, 'MSGTFRDR')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1053, 1, 1008, '91_', 120, 'MSGTCHBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1054, 1, 1008, '93_', 130, 'MSGTCHBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1055, 1, 1008, '90_', 140, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1056, 1, 1008, '92_', 150, 'MSGTREPR')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (1057, 1, 1008, '933', 125, 'MSGTDADV')
/
update net_msg_type_map set msg_type = 'MSGTREPR' where id = 1055
/
