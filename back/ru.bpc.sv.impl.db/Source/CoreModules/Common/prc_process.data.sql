insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000805, 'com_prc_sttl_day_pkg.switch_sttl_day', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000024, 'COM_PRC_RATE_PKG.LOAD_RATES', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000856, 'UTL_DEPLOY_PKG.CLEAR_USER_TABLES', 0, 9999, 0, 0)
/
update prc_process set procedure_name = 'UTL_PRC_CLEAR_PKG.CLEAR_USER_TABLES' where id = 10000856
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000900, 'COM_PRC_RATE.UNLOAD_RATES', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000904, 'ru.bpc.sv2.scheduler.process.external.svng.MqPostingLoadProcess', 0, 9999, 1, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000905, NULL, 0, 9999, 0, 1, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000906, NULL, 0, 9999, 0, 1, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000907, NULL, 0, 9999, 0, 1, 0)
/
update prc_process set procedure_name = 'COM_PRC_RATE_PKG.UNLOAD_RATES' where id = 10000900
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000945, NULL, 0, 9999, 0, 1, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000961, 'ru.bpc.sv2.scheduler.process.svng.mastercard.MpeProcessLoadHandler', 0, 9999, 1, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000962, 'ru.bpc.sv2.scheduler.process.svng.mastercard.IpmProcessLoadHandler', 0, 9999, 1, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001017, NULL, 0, 9999, 0, 1, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001100, 'COM_PRC_DICT_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001122, 'COM_PRC_MCC_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
