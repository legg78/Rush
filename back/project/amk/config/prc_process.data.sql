insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000090, 'CST_AMK_AGENTS_AWARDING_PKG.CALCULATE_AWARDING', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000144, 'CST_AMK_AGENTS_AWARDING_PKG.CALCULATE_PILOT_BONUS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000145, 'CST_AMK_AGENTS_AWARDING_PKG.CALCULATE_PERIODIC_BONUS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000151, 'CST_AMK_REPORT_PKG.CALCULATE_AGENTS_STATISTIC', 0, 9999, 0, 0, 0)
/
delete from prc_process where id = -50000151
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000179, 'CST_AMK_PRC_OUTGOING_PKG.PROCESS_FEES_TO_T24_EXPORT', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000182, 'CST_AMK_PRC_OUTGOING_PKG.PROCESS_TRANS_EXPORT_TO_TELCO', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000281, 'CST_AMK_RCN_PRC_PKG.PROCESS_INCOMING_TRANSACTION', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000286, 'CST_AMK_PRC_OUTGOING_PKG.PROCESS_FEES_TO_T24_CSV', 0, 9999, 0, 0, 0)
/
