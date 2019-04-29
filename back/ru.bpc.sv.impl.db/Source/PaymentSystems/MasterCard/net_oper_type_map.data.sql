insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1001, 1, 1016, '00', 1, 'OPTP0000')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1002, 1, 1016, '01', 1, 'OPTP0001')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1003, 1, 1016, '09', 1, 'OPTP0009')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1004, 1, 1016, '12', 1, 'OPTP0012')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1005, 1, 1016, '18', 1, 'OPTP0018')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1006, 1, 1016, '19', 1, 'OPTP0019')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1007, 1, 1016, '20', 1, 'OPTP0020')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1008, 1, 1016, '28', 1, 'OPTP0028')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1009, 1, 1016, '29', 1, 'OPTP0029')
/
update net_oper_type_map set network_oper_type = '00____' where id = 1001
/
update net_oper_type_map set network_oper_type = '01____' where id = 1002
/
update net_oper_type_map set network_oper_type = '09____' where id = 1003
/
update net_oper_type_map set network_oper_type = '12____' where id = 1004
/
update net_oper_type_map set network_oper_type = '18____' where id = 1005
/
update net_oper_type_map set network_oper_type = '19____' where id = 1006
/
update net_oper_type_map set network_oper_type = '20____' where id = 1007
/
update net_oper_type_map set network_oper_type = '28____' where id = 1008
/
update net_oper_type_map set network_oper_type = '29____' where id = 1009
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1076, 1, 1016, '006538', 2, 'OPTP0010')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1077, 1, 1016, '286536', 3, 'OPTP0026')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1078, 1, 1016, '286537', 4, 'OPTP0026')
/
update net_oper_type_map set priority = 100 where id = 1008
/
update net_oper_type_map set priority = 100 where id = 1001
/
update net_oper_type_map set priority = 1 where id = 1076
/
update net_oper_type_map set priority = 1 where id = 1077
/
update net_oper_type_map set priority = 2 where id = 1078
/
