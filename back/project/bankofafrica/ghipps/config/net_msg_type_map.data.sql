insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5015, 1, 5003, '10_', 100, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5016, 1, 5003, '12_', 110, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5017, 1, 5003, '119', 120, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5018, 1, 5003, '11_', 130, 'MSGTCHBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5019, 1, 5003, '13_', 140, 'MSGTCHBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5020, 1, 5003, '20_', 150, 'MSGTREPR')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5021, 1, 5003, '22_', 160, 'MSGTREPR')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5022, 1, 5003, '219', 170, 'MSGTREPR')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5023, 1, 5003, '21_', 180, 'MSGTACBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5024, 1, 5003, '23_', 190, 'MSGTACBK')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5025, 1, 5003, '_10', 200, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5026, 1, 5003, '_20', 210, 'MSGTPRES')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5027, 1, 5003, '5', 220, 'MSGTRTRQ')
/
insert into net_msg_type_map (id, seqnum, standard_id, network_msg_type, priority, msg_type) values (-5028, 1, 5003, '_40', 230, 'MSGTFRDR')
/
update net_msg_type_map set network_msg_type = '15_' where id = -5027
/
