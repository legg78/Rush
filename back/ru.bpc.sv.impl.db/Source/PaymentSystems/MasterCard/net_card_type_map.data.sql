insert into net_card_type_map (id, seqnum, card_type_id, standard_id, network_card_type, priority) values (10000036, 1, 1006, 1002, 'CIR___', 200)
/
insert into net_card_type_map (id, seqnum, card_type_id, standard_id, network_card_type, priority) values (10000037, 1, 1005, 1002, 'DMC___', 100)
/
insert into net_card_type_map (id, seqnum, card_type_id, standard_id, network_card_type, priority) values (10000045, 1, 1006, 1002, 'MAV___', 200)
/
insert into net_card_type_map (id, seqnum, card_type_id, standard_id, network_card_type, priority) values (10000046, 1, 1005, 1002, 'MCC___', 100)
/
insert into net_card_type_map (id, seqnum, card_type_id, standard_id, network_card_type, priority) values (10000067, 1, 1006, 1002, 'MSI___', 200)
/
insert into net_card_type_map (id, seqnum, card_type_id, standard_id, network_card_type, priority) values (10000068, 1, 1006, 1002, 'PRO___', 200)
/
insert into net_card_type_map (id, seqnum, card_type_id, standard_id, network_card_type, priority) values (10000070, 1, 1005, 1002, 'PVL___', 100)
/
insert into net_card_type_map (id, seqnum, card_type_id, standard_id, network_card_type, priority) values (10000071, 1, 1006, 1002, 'SOL___', 200)
/
insert into net_card_type_map (id, seqnum, card_type_id, standard_id, network_card_type, priority) values (10000072, 1, 1006, 1002, 'SWI___', 200)
/
update net_card_type_map set standard_id = 1016 where id in (10000036,10000037,10000045,10000046,10000067,10000068,10000070,10000071,10000072)
/
update net_card_type_map set card_type_id = 1006 where id in (10000037, 10000046, 10000070)
/
update net_card_type_map set card_type_id = 1005 where id in (10000072, 10000071, 10000068, 10000067, 10000045, 10000036)
/
 