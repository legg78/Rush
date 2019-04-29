insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000137, 1, 1032, 'S__', 100, 1034, NULL)
/
insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000138, 1, 1032, 'G__', 100, 1035, NULL)
/
insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000139, 1, 1032, 'P__', 100, 1036, NULL)
/
insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000140, 1, 1032, 'R__', 100, 1036, NULL)
/
insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000141, 1, 1032, 'C__', 100, 1037, NULL)
/
insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000142, 1, 1032, 'O__', 100, 1038, NULL)
/
insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000163, 1, 1032, 'R__', 100, 1062, NULL)
/
insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000164, 1, 1032, 'D__', 100, 1063, NULL)
/
insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000165, 1, 1032, 'E__', 100, 1064, NULL)
/
insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000166, 1, 1032, 'M__', 100, 1065, NULL)
/
insert into net_card_type_map (id, seqnum, standard_id, network_card_type, priority, card_type_id, country) values (10000167, 1, 1032, 'U__', 100, 1066, NULL)
/
delete from net_card_type_map where id = 10000163
/
update net_card_type_map set card_type_id = 1062 where id = 10000140
/
