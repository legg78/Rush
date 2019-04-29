insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (-50000001, 1, -5001, 1394, 10)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (-50000002, 1, -5002, 1399, 10)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (-50000003, 1, -5003, -5040, 10)
/
insert into rul_rule (id, seqnum, rule_set_id, proc_id, exec_order) values (-50000004, 1, -5004, -5041, 10)
/
update rul_rule set proc_id = 1394 where id = -50000003
/
update rul_rule set proc_id = 1399 where id = -50000004
/
update rul_rule set proc_id = -5040 where id = -50000003
/
update rul_rule set proc_id = -5041 where id = -50000004
/
