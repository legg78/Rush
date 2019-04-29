insert into rul_proc (id, proc_name, category) values (1270, 'lty_api_bonus_pkg.spend_bonus_auth', 'RLCGAUTH')
/
insert into rul_proc (id, proc_name, category) values (1309, 'lty_prc_bonus_pkg.export_bonus_file', 'RLCGEVNT')
/
delete from rul_proc where id = 1309
/
insert into rul_proc (id, proc_name, category) values (1568, 'evt_api_rule_proc_pkg.check_lty_account_on_card', 'RLCGEVNT')
/
delete from rul_proc where id = 1270
/
update rul_proc set proc_name = 'evt_api_rule_proc_pkg.check_lty_account' where id = 1568
/
insert into rul_proc (id, proc_name, category) values (1661, 'opr_api_rule_proc_pkg.lottery_ticket_registration', 'RLCGOPRP')
/
update rul_proc set proc_name = 'lty_api_rule_proc_pkg.lottery_ticket_registration' where id = 1661
/
update rul_proc set proc_name = 'lty_api_rule_proc_pkg.check_lty_account' where id = 1568
/
insert into rul_proc (id, proc_name, category) values (1674, 'lty_api_rule_proc_pkg.get_account_balance', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1675, 'lty_api_rule_proc_pkg.calculate_lty_points', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1676, 'lty_api_rule_proc_pkg.move_bonus_oper', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1694, 'lty_api_rule_proc_pkg.spend_operation', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1762, 'lty_api_rule_proc_pkg.check_promo_level_turnover', 'RLCGALGP')
/
update rul_proc set proc_name = 'lty_api_algo_proc_pkg.check_promo_level_turnover' where id = 1762
/
