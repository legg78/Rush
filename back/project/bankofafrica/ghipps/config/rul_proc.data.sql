insert into rul_proc (id, proc_name, category) values (-5021, 'cst_bof_ghp_api_rule_proc_pkg.create_fin_message', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (-5022, 'cst_bof_ghp_api_dsp_gen_pkg.fraud_reporting', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5023, 'cst_bof_ghp_api_dsp_init_pkg.pres_chargeback_reversal', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5024, 'cst_bof_ghp_api_dsp_init_pkg.second_presentment', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5025, 'cst_bof_ghp_api_dsp_init_pkg.second_chargeback', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5026, 'cst_bof_ghp_api_dsp_init_pkg.second_presentment_reversal', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5027, 'cst_bof_ghp_api_dsp_init_pkg.retrieval_request', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5028, 'cst_bof_ghp_api_dsp_init_pkg.fee_collection', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5029, 'cst_bof_ghp_api_dsp_init_pkg.funds_disbursement', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5030, 'cst_bof_ghp_api_dsp_init_pkg.fraud_reporting', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5031, 'cst_bof_ghp_api_dsp_init_pkg.first_chargeback', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5032, 'cst_bof_ghp_api_dsp_gen_pkg.first_chargeback', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5033, 'cst_bof_ghp_api_dsp_gen_pkg.pres_chargeback_reversal', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5034, 'cst_bof_ghp_api_dsp_gen_pkg.second_presentment', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5035, 'cst_bof_ghp_api_dsp_gen_pkg.second_chargeback', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5036, 'cst_bof_ghp_api_dsp_gen_pkg.second_presentment_reversal', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5037, 'cst_bof_ghp_api_dsp_gen_pkg.retrieval_request', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5038, 'cst_bof_ghp_api_dsp_gen_pkg.fee_collection', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5039, 'cst_bof_ghp_api_dsp_gen_pkg.funds_disbursement', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5043, 'cst_bof_ghp_api_rule_proc_pkg.load_dispute_parameters', 'RLCGDISP')
/
update rul_proc set proc_name = 'cst_bof_ghp_api_dsp_gen_pkg.fee_debit_credit' where id = -5038
/
delete from rul_proc where id = -5039
/
