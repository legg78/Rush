insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5007, 1, 5003, '5____', 100, 'OPTP0000')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5008, 1, 5003, '_76011', 110, 'OPTP0001')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5009, 1, 5003, '_76010', 120, 'OPTP0009')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5010, 1, 5003, '6____', 130, 'OPTP0020')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5011, 1, 5003, '10____', 140, 'OPTP0019')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5012, 1, 5003, '20____', 150, 'OPTP0029')
/
update net_oper_type_map set network_oper_type = '_5____' where id = -5007
/
update net_oper_type_map set network_oper_type = '_6____' where id = -5010
/
update net_oper_type_map set network_oper_type = '10_' where id = -5011
/
update net_oper_type_map set network_oper_type = '20_' where id = -5012
/
update net_oper_type_map set network_oper_type = '10%' where id = -5011
/
update net_oper_type_map set network_oper_type = '20%' where id = -5012
/
