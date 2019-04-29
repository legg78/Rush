insert into rul_proc (id, proc_name, category) values (1148, 'iss_api_event_pkg.create_card_fee', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1187, 'iss_api_event_pkg.calculate_reissue_date', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1188, 'iss_api_event_pkg.reissue_card_instance', 'RLCGEVNT')
/
update rul_proc set proc_name = 'iss_api_event_pkg.create_event_fee' where id = 1148
/
insert into rul_proc (id, proc_name, category) values (1572, 'iss_api_rule_proc_pkg.create_virtual_card', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1574, 'iss_api_event_pkg.get_card_balance', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1658, 'evt_api_rule_proc_pkg.change_card_delivery_status', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1750, 'evt_api_rule_proc_pkg.close_dependent_objects', 'RLCGEVNT')
/
update rul_proc set proc_name = 'iss_api_rule_proc_pkg.create_event_fee' where id = 1148
/
update rul_proc set proc_name = 'iss_api_rule_proc_pkg.calculate_reissue_date' where id = 1187
/
update rul_proc set proc_name = 'iss_api_rule_proc_pkg.reissue_card_instance' where id = 1188
/
update rul_proc set proc_name = 'iss_api_rule_proc_pkg.get_card_balance' where id = 1574
/
