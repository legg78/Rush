insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000001, 1, -50000001, 10000448, 'CYTP5112')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000003, 1, -50000001, 10000714, 'TMAM0000')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000004, 1, -50000002, 10000482, 'CYTP5114')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000005, 1, -50000002, 10000712, 'TMAM0000')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000006, 1, -50000003, -50000007, 'CYTP5111')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000007, 1, -50000003, -50000008, 'TMAM2001')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000008, 1, -50000004, -50000009, 'CYTP5113')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000009, 1, -50000004, -50000010, 'TMAM2001')
/
delete from rul_rule_param_value where id = -50000006
/
delete from rul_rule_param_value where id = -50000007
/
delete from rul_rule_param_value where id = -50000008
/
delete from rul_rule_param_value where id = -50000009
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000010, 1, -50000003, 10000448, 'CYTP5111')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000011, 1, -50000003, 10000714, 'TMAM2001')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000012, 1, -50000004, 10000482, 'CYTP5113')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (-50000013, 1, -50000004, 10000712, 'TMAM2001')
/
update rul_rule_param_value set proc_param_id = -50000007 where id = -50000010
/
update rul_rule_param_value set proc_param_id = -50000008 where id = -50000011
/
update rul_rule_param_value set proc_param_id = -50000009 where id = -50000012
/
update rul_rule_param_value set proc_param_id = -50000010 where id = -50000013
/
