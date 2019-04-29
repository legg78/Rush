delete net_network where id = 1010
/
insert into net_network (id, seqnum, inst_id, bin_table_scan_priority) values (1010, 1, 9011, 100)
/
update net_network set bin_table_scan_priority = 120 where id = 1010
/

