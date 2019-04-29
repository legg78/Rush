insert into rul_proc (id, proc_name, category) values (1550, 'crd_api_rule_proc_pkg.debt_in_collection', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1552, 'crd_api_rule_proc_pkg.resume_credit_calc', 'RLCGOPRP')
/
update rul_proc set proc_name = 'crd_api_rule_proc_pkg.suspend_credit_calc' where id = 1552
/
insert into rul_proc (id, proc_name, category) values (1553, 'crd_api_rule_proc_pkg.continue_credit_calc', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1554, 'crd_api_rule_proc_pkg.cancel_credit_calc', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1563, 'crd_api_rule_proc_pkg.credit_limit_increase', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1573, 'crd_api_rule_proc_pkg.calc_total_accrued_amount', 'RLCGOPRP')
/
update rul_proc set proc_name = 'crd_api_rule_proc_pkg.credit_clearance' where id = 1167
/
update rul_proc set proc_name = 'crd_api_rule_proc_pkg.credit_payment' where id = 1168
/
insert into rul_proc (id, proc_name, category) values (1657, 'opr_api_rule_proc_pkg.calculate_credit_overlimit_fee', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1669, 'evt_api_rule_proc_pkg.calc_part_interest_return', 'RLCGEVNT')
/
update rul_proc set proc_name = 'crd_api_rule_proc_pkg.calc_part_interest_return' where id = 1669
/
update rul_proc set proc_name = 'crd_api_rule_proc_pkg.calculate_credit_overlimit_fee' where id = 1657
/
insert into rul_proc (id, proc_name, category) values (1691, 'crd_api_rule_proc_pkg.calc_accrued_amount', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1705, 'crd_api_rule_proc_pkg.lending_clearance', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1706, 'crd_api_rule_proc_pkg.lending_payment', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (1708, 'crd_api_rule_proc_pkg.incr_aging_period', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1709, 'crd_api_rule_proc_pkg.reset_aging_period', 'RLCGEVNT')
/
delete rul_proc where id = 1708
/
insert into rul_proc (id, proc_name, category) values (1725, 'crd_api_rule_proc_pkg.load_invoice_data', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1733, 'crd_api_rule_proc_pkg.set_skip_mad_date', 'RLCGEVNT')
/
insert into rul_proc (id, proc_name, category) values (1765, 'crd_api_rule_proc_pkg.credit_balance_transfer', 'RLCGOPRP')
/
delete rul_proc where id = 1733
/
insert into rul_proc (id, proc_name, category) values (1780, 'crd_api_algo_proc_pkg.mad_algorithm_threshold', 'RLCGALGP')
/
insert into rul_proc (id, proc_name, category) values (1788, 'crd_api_rule_proc_pkg.revert_interest', 'RLCGOPRP')
/
