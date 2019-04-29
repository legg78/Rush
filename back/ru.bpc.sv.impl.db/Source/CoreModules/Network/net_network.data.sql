insert into net_network (id, seqnum, inst_id, bin_table_scan_priority) values (1001, 1, 1001, 100)
/
insert into net_network (id, seqnum, inst_id, bin_table_scan_priority) values (1002, 1, 9001, 200)
/
insert into net_network (id, seqnum, inst_id, bin_table_scan_priority) values (1003, 1, 9002, 300)
/
insert into net_network (id, seqnum, inst_id, bin_table_scan_priority) values (9998, 1, 9999, 100)
/
insert into net_network (id, seqnum, inst_id, bin_table_scan_priority) values (1004, 1, 9003, 400)
/
insert into net_network (id, seqnum, inst_id, bin_table_scan_priority) values (1005, 1, 9004, 500)
/
insert into net_network (id, seqnum, inst_id, bin_table_scan_priority) values (1006, 1, 9005, 450)
/
update net_network set bin_table_scan_priority = 150 where id = 1006
/
update net_network set bin_table_scan_priority = 125 where id = 1004
/
insert into net_network (id, seqnum, inst_id, bin_table_scan_priority) values (1008, 1, 9008, 130)
/
insert into net_network (id, seqnum, inst_id, bin_table_scan_priority) values (1009, 1, 9009, 140)
/
