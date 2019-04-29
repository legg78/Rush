insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000001, 1, 1002, 10000777, 'CYTP0100')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000002, 1, 1003, 10000777, 'CYTP0102')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000003, 1, 1005, 10000482, 'CYTP0102')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000004, 1, 1005, 10000712, 'TMAM0000')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000005, 1, 1006, 10000459, 'FETP0102')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000006, 1, 1006, 10000711, 'TMAM0000')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000007, 1, 1007, 10000490, 'FETP0102')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000008, 1, 1007, 10000491, 'OPTP0119')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000009, 1, 1007, 10000931, 'PRTYISS')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000010, 1, 1008, 10000777, 'CYTP0104')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000011, 1, 1009, 10000827, 'EVNT0103')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000012, 1, 1009, 10000944, '000000000000000001.0000')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000013, 1, 1010, 10000783, 'EVNT0103')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000014, 1, 1011, 10000482, 'CYTP0104')
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000015, 1, 1011, 10000712, 'TMAM0000')
/
--Setting mandatory parameters value for Rulset 'Charge card maintenance fee' and Rule evt_api_rule_proc_pkg.calculate_fee--
delete rul_rule_param_value where id = 10000016
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000016, 1, 1006, 10000464, 'FETP0102')
/
delete from rul_rule_param_value where id in (10000003, 10000004)
/
insert into rul_rule_param_value (id, seqnum, rule_id, proc_param_id, param_value) values (10000017, 1, 1014, 10000256, 'CYTP0102')
/

