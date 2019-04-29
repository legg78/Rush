insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5006, 1, 5001, '20____', 150, 'OPTP0029')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5005, 1, 5001, '10____', 140, 'OPTP0019')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5004, 1, 5001, '6____', 130, 'OPTP0020')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5003, 1, 5001, '_7_6010', 120, 'OPTP0009')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5002, 1, 5001, '_7_6011', 110, 'OPTP0001')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5001, 1, 5001, '5____', 100, 'OPTP0000')
/
update net_oper_type_map set network_oper_type = '_76010' where id = -5003
/
update net_oper_type_map set network_oper_type = '_76011' where id = -5002
/
update net_oper_type_map set network_oper_type = '_5____' where id = -5001
/
update net_oper_type_map set network_oper_type = '_6____' where id = -5004
/
update net_oper_type_map set network_oper_type = '10_' where id = -5005
/
update net_oper_type_map set network_oper_type = '20_' where id = -5006
/
update net_oper_type_map set network_oper_type = '10%' where id = -5005
/
update net_oper_type_map set network_oper_type = '20%' where id = -5006
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5028, 1, 5001, '49____', 250, 'OPTP0000')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (-5027, 1, 5001, '496011', 200, 'OPTP0001')
/

