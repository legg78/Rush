insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000835, 'PMO_PRC_EXPORT_PKG.CREATE_XML_FILE', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000846, 'PMO_PRC_SCHEDULE_PKG.PROCESS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000010, 'ru.bpc.sv2.scheduler.process.external.PaymentOrderProcessing', 0, 9999, 1, 0)
/
update prc_process set is_parallel = 1 where id = 10000846
/
update prc_process set procedure_name = 'PMO_PRC_EXPORT_PKG.PROCESS' where id = 10000835
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001093, 'PMO_PRC_IMPORT_PKG.IMPORT_PMO_RESPONSE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001096, 'PMO_PRC_RETRY_PKG.PROCESS', 1, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001157, 'PMO_PRC_IMPORT_PKG.IMPORT_ORDERS', 0, 9999, 0, 0, 0)
/
