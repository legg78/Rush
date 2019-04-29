insert into fcl_cycle (id, seqnum, cycle_type, length_type, cycle_length, trunc_type, inst_id) values (10000001, 1, 'CYTPPRTN', 'LNGT0004', 1, 'LNGT0004', 9999)
/
insert into fcl_cycle (id, seqnum, cycle_type, length_type, cycle_length, trunc_type, inst_id) values (10000002, 1, 'CYTPPRTN', 'LNGT0005', 2, 'LNGT0004', 9999)
/
update fcl_cycle set cycle_type = 'CYTPDRPP' where id = 10000002
/
