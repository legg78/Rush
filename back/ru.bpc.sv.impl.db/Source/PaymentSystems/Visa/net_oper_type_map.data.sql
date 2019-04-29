insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1, 1, 1008, '00_____', 10, 'OPTP0000')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (2, 1, 1008, '07_6011', 1, 'OPTP0001')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (3, 1, 1008, '07_6012', 1, 'OPTP0012')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (4, 1, 1008, '06_____', 1, 'OPTP0022')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (5, 1, 1008, '050____', 1, 'OPTP0010')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (6, 1, 1008, '062____', 1, 'OPTP0026')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (7, 1, 1008, '20_____', 110, 'OPTP0000')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (8, 1, 1008, '27_6011', 100, 'OPTP0001')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (9, 1, 1008, '27_6012', 100, 'OPTP0012')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (10, 1, 1008, '26_____', 100, 'OPTP0022')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (11, 1, 1008, '250____', 100, 'OPTP0010')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (12, 1, 1008, '262____', 100, 'OPTP0026')
/
delete from net_oper_type_map where id in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1, 1, 1008, '_5_____', 10, 'OPTP0000')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (2, 1, 1008, '_7_6011', 1, 'OPTP0001')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (3, 1, 1008, '_7_6010', 1, 'OPTP0012')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (4, 1, 1008, '_60____', 1, 'OPTP0020')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (5, 1, 1008, '_61____', 1, 'OPTP0028')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (6, 1, 1008, '_62____', 1, 'OPTP0010')
/
update net_oper_type_map set oper_type = 'OPTP0026' where id = 6
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (24, 1, 1008, '100', 10, 'OPTP0019')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (25, 1, 1008, '200', 10, 'OPTP0029')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1016, 1, 1008, '106050', 1, 'OPTP1128')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1017, 1, 1008, '106060', 1, 'OPTP1102')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1018, 1, 1008, '206040', 2, 'OPTP1128')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1019, 1, 1008, '206070', 2, 'OPTP1102')
/
update net_oper_type_map set network_oper_type = '10____' where id = 24
/
update net_oper_type_map set network_oper_type = '20____' where id = 25
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1020, 1, 1008, '_7_6051', 1, 'OPTP0018')
/
delete net_oper_type_map where id = 1021
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1021, 1, 1008, '_7_4814', 3, 'OPTP0012')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1074, 1, 1008, '_51____', 5, 'OPTP0010')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1075, 1, 1008, '_606012', 6, 'OPTP0026')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1127, 1, 1008, '_6_____MP', 1, 'OPTP0050')
/
insert into net_oper_type_map (id, seqnum, standard_id, network_oper_type, priority, oper_type) values (1128, 1, 1008, '_6_____C', 1, 'OPTP0051')
/
update net_oper_type_map set priority = 2 where id = 5
/
update net_oper_type_map set priority = 2 where id = 6
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 1
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 2
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 3
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 4
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 24
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 25
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 1016
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 1017
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 1018
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 1019
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 1020
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 1021
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 1074
/
update net_oper_type_map set network_oper_type = network_oper_type || '__' where id = 1075
/
update net_oper_type_map set network_oper_type = '_6_____CO' where id = 1128
/
update net_oper_type_map set priority = 2 where id = 4
/
