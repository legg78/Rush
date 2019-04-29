insert into prc_process(id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000045, 'APP_PRC_PROCESS_PKG.EVENT_UPLOAD_APP_RESPONSE', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000836, 'APP_PRC_APPLICATION_PKG.PROCESS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000046, 'ru.bpc.sv2.scheduler.process.external.btrt.BTRTProcessor', 0, 9999, 1, 0)
/
update prc_process set procedure_name = 'APP_PRC_RESPONSE_PKG.EVENT_UPLOAD_APP_RESPONSE' where id = 10000045
/
update prc_process set is_parallel = 1 where id = 10000836
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000879, 'APP_PRC_APPLICATION_PKG.PROCESS_MIGRATE', 1, 9999, 0, 0)
/
update prc_process set is_parallel = 0 where id = 10000836
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001162, 'APP_PRC_APPLICATION_PKG.PARALLEL_PROCESS', 1, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001164, NULL, 0, 9999, 0, 1, 0)
/
