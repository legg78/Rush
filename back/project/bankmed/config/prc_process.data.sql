insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (50000001, 'CST_BMED_ACCOUNT_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (50000002, 'CST_BMED_CARD_EXPORT_PKG.EXPORT_BARCODES', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (50000003, 'CST_BMED_CSC_INCOMING_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (50000004, 'CST_BMED_CSC_OUTGOING_PKG.EXPORT_CSC_REPORT', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (50000005, 'CST_BMED_PRC_CMO_PKG.UNLOADING_CMO_FILE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (50000035, 'CST_BMED_PRC_OUTGOING_CBS_PKG.UNLOADING_CBS_FILE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000167, 'CST_BMED_PRC_OUTGOING_PKG.PROCESS_EXPORT_CBS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000170, 'CST_BMED_PRC_OUTGOING_PKG.PROCESS_EXPORT_RTGS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000168, 'CST_BMED_PRC_INCOMING_PKG.PROCESS_IMPORT_RGTS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000175, 'CST_BMED_CRD_PRC_BILLING_PKG.PROCESS_SUBSIDY', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000176, 'CST_BMED_CRD_PRC_BILLING_PKG.PROCESS_SHARING', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000186, 'CST_BMED_LTY_PRC_BONUS_PKG.EXPORT_BONUS_FIN_GATE_FILE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000185, 'CST_BMED_LTY_PRC_BONUS_PKG.EXPORT_BONUS_SPENDING_FILE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000184, 'CST_BMED_LTY_PRC_BONUS_PKG.EXPORT_NEW_MEMBERS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000192, 'CST_BMED_PRC_OUTGOING_PKG.GENERATE_POSINP_FILE', 0, 9999, 0, 0, 0)
/
delete from prc_process where id = -50000186
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000287, 'CST_BMED_PRC_INCOMING_PKG.PROCESS_IMPORT_ACCOUNT_STATUS', 0, 9999, 0, 0, 0)
/
