insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1115, 1, 1024, '____000000____', 10, 'OPTP0000')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1116, 1, 1024, '____0100006011', 20, 'OPTP0001')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1117, 1, 1024, '____1708086011', 30, 'OPTP0001')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1118, 1, 1024, '____0140086010', 40, 'OPTP0012')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1119, 1, 1024, '____200000____', 50, 'OPTP0020')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1120, 1, 1024, '____220000____', 60, 'OPTP0022')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1121, 1, 1024, '1744000000____', 70, 'OPTP0029')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1122, 1, 1024, '1744200000____', 80, 'OPTP0019')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1123, 1, 1024, '17400100006011', 90, 'OPTP0029')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1124, 1, 1024, '17422800006011', 100, 'OPTP0019')
/
update net_oper_type_map set network_oper_type = '1740010000____' where id = 1123
/
update net_oper_type_map set network_oper_type = '1742280000____' where id = 1124
/
update net_oper_type_map set priority = 110 where id = 1115 and standard_id = 1024
/
update net_oper_type_map set priority = 120 where id = 1116 and standard_id = 1024
/
update net_oper_type_map set priority = 130 where id = 1117 and standard_id = 1024
/
update net_oper_type_map set priority = 140 where id = 1118 and standard_id = 1024
/
update net_oper_type_map set priority = 150 where id = 1119 and standard_id = 1024
/
update net_oper_type_map set priority = 160 where id = 1120 and standard_id = 1024
/
