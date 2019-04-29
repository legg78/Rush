insert into rul_proc (id, proc_name, category) values (-5002, 'cst_bof_gim_api_rule_proc_pkg.create_fin_message', 'RLCGOPRP')
/
insert into rul_proc (id, proc_name, category) values (-5003, 'cst_bof_gim_api_dsp_init_pkg.first_chargeback', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5004, 'cst_bof_gim_api_dsp_init_pkg.pres_chargeback_reversal', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5005, 'cst_bof_gim_api_dsp_init_pkg.second_presentment', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5006, 'cst_bof_gim_api_dsp_init_pkg.second_chargeback', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5007, 'cst_bof_gim_api_dsp_init_pkg.second_presentment_reversal', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5008, 'cst_bof_gim_api_dsp_init_pkg.retrieval_request', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5009, 'cst_bof_gim_api_dsp_init_pkg.fee_collection', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5010, 'cst_bof_gim_api_dsp_init_pkg.funds_disbursement', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5011, 'cst_bof_gim_api_dsp_init_pkg.fraud_reporting', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5012, 'cst_bof_gim_api_dsp_gen_pkg.first_chargeback', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5013, 'cst_bof_gim_api_dsp_gen_pkg.pres_chargeback_reversal', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5014, 'cst_bof_gim_api_dsp_gen_pkg.second_presentment', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5015, 'cst_bof_gim_api_dsp_gen_pkg.second_chargeback', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5016, 'cst_bof_gim_api_dsp_gen_pkg.second_presentment_reversal', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5017, 'cst_bof_gim_api_dsp_gen_pkg.retrieval_request', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5018, 'cst_bof_gim_api_dsp_gen_pkg.fee_collection', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5019, 'cst_bof_gim_api_dsp_gen_pkg.funds_disbursement', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5020, 'cst_bof_gim_api_dsp_gen_pkg.fraud_reporting', 'RLCGDISP')
/
insert into rul_proc (id, proc_name, category) values (-5042, 'cst_bof_gim_api_rule_proc_pkg.load_dispute_parameters', 'RLCGDISP')
/
update rul_proc set proc_name = 'cst_bof_gim_api_dsp_gen_pkg.fee_debit_credit' where id = -5018
/
delete from rul_proc where id = -5019
/
insert into rul_proc (id, proc_name, category) values (-5079, 'cst_bof_gim_api_rule_proc_pkg.load_gim_message_params', 'RLCGOPRP')
/
