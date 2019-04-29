insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1030, 1, 1035, '00____', 1, 'OPTP0000')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1031, 1, 1035, '01____', 1, 'OPTP0001')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1032, 1, 1035, '12____', 1, 'OPTP0012')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1033, 1, 1035, '19____', 1, 'OPTP0019')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1034, 1, 1035, '20____', 1, 'OPTP0020')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1035, 1, 1035, '26____', 1, 'OPTP0022')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1036, 1, 1035, '28____', 1, 'OPTP0028')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1037, 1, 1035, '29____', 1, 'OPTP0029')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1072, 1, 1035, '22____', 1, 'OPTP0027')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1079, 1, 1035, '27____', 1, 'OPTP0022')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1112, 1, 1035, '02____', 1, 'OPTP0002')
/
update net_oper_type_map set oper_type = '266012' where id = 1035
/
update net_oper_type_map set oper_type = '276012' where id = 1079
/
update net_oper_type_map set oper_type = '286536' where id = 1036
/
update net_oper_type_map set oper_type = 'OPTP0022', network_oper_type = '266012' where id = 1035
/
update net_oper_type_map set oper_type = 'OPTP0022', network_oper_type = '276012' where id = 1079
/
update net_oper_type_map set oper_type = 'OPTP0028', network_oper_type = '286536' where id = 1036
/
