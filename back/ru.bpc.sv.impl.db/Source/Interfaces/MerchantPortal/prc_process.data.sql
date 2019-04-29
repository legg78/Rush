insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001054, 'ITF_MPT_PRC_CUST_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001055, 'ITF_MPT_PRC_ACQ_EXPORT_PKG.PROCESS_MERCHANT', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001056, 'ITF_MPT_PRC_ACQ_EXPORT_PKG.PROCESS_TERMINAL', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001057, 'ITF_MPT_PRC_OPER_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001058, 'ITF_MPT_PRC_DICT_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
delete from prc_process where id = 10001058
/
