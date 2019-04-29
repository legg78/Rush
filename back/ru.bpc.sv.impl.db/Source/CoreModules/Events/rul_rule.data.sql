insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (1012, 1, 1009, 1581, 10)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000022, 1, 1024, 1400, 10)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000019, 1, 1022, 1434, 10)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000020, 1, 1022, 1152, 30)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000021, 1, 1022, 1154, 20)
/
update rul_rule set exec_order = 20 where id = 10000022
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000023, 1, 1024, 1579, 10)
/
update rul_rule set exec_order = 50 where id = 10000020
/
delete from rul_rule where id = 10000021
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000021, 1, 1022, 1155, 20)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000024, 1, 1022, 1228, 30)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000025, 1, 1022, 1228, 40)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000027, 1, 1026, 1668, 10)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000028, 1, 1026, 1400, 20)
/
delete from rul_rule where id = 10000024
/
delete from rul_rule where id = 10000025
/
update rul_rule set exec_order = 30 where id = 10000020
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000032, 1, 1030, 1727, 10)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (10000033, 1, 1030, 1456, 20)
/
