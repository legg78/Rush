insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1028, 1, 1034, '100', 10, 'OPTP0000')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1029, 1, 1034, '101', 20, 'OPTP0020')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1073, 1, 1034, '700', 20, 'OPTP0000')
/

update net_oper_type_map set network_oper_type = '100%' where id = 1028
/
update net_oper_type_map set network_oper_type = '101%' where id = 1029
/
update net_oper_type_map set network_oper_type = '700%', priority = 30 where id =1073
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1129, 1, 1034, '10029', 5, 'OPTP0026')
/
