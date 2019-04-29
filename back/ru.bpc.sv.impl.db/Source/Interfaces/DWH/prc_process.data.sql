insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001043, 'ITF_DWH_PRC_CUST_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001044, 'ITF_DWH_PRC_ACC_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001045, 'ITF_DWH_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_NUMBERS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001046, 'ITF_DWH_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_STATUS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001047, 'ITF_DWH_PRC_ACQ_EXPORT_PKG.PROCESS_MERCHANT', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001048, 'ITF_DWH_PRC_ACQ_EXPORT_PKG.PROCESS_TERMINAL', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001049, 'ITF_DWH_PRC_OPER_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001050, 'ITF_DWH_PRC_DICT_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
delete prc_process where id = 10001050
/
