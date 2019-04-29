insert into rul_proc (id, proc_name, category) values (1701, 'dpp_api_rule_proc_pkg.accelerate_dpps', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1707, 'dpp_api_rule_proc_pkg.register_instalment_event', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1728, 'dpp_api_rule_proc_pkg.check_dpp_account', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1777, 'dpp_api_rule_proc_pkg.cancel_dpp', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1776, 'dpp_api_rule_proc_pkg.load_dpp_data', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1779, 'dpp_api_rule_proc_pkg.restructure_dpp', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1781, 'dpp_api_rule_proc_pkg.calc_gih', 'RLCGALGP')
/
insert into rul_proc (id, proc_name, category) values (1782, 'dpp_api_rule_proc_pkg.calc_balloon', 'RLCGALGP')
/
update rul_proc set proc_name = 'dpp_api_algo_proc_pkg.calc_gih' where id = 1781
/
update rul_proc set proc_name = 'dpp_api_algo_proc_pkg.calc_balloon' where id = 1782
/
