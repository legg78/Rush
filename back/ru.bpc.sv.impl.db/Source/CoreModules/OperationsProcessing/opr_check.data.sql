insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1001, 1, 1001, 'OPCK0001', 10)
/
insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1002, 1, 1001, 'OPCK0200', 20)
/
insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1003, 1, 1002, 'OPCK0201', 10)
/
insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1004, 1, 1002, 'OPCK0202', 20)
/
insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1005, 1, 1002, 'OPCK0203', 30)
/
insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1006, 1, 1003, 'OPCK0101', 10)
/
insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1007, 1, 1004, 'OPCK0100', 10)
/
insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1008, 1, 1004, 'OPCK0102', 20)
/
insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1009, 1, 1005, 'OPCK0203', 10)
/
insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1010, 1, 1006, 'OPCK0205', 10)
/
delete opr_check where id = 1005
/
delete from opr_check where id in ('1005', '1009')
/
delete from opr_check where id = 1010
/
insert into opr_check (id, seqnum, check_group_id, check_type, exec_order) values (1009, 1, 1007, 'OPCK0400', 10)
/
