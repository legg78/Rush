insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000263, 'CRD_PRC_BILLING_PKG.PROCESS', 1, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000866, 'CRD_API_REPORT_PKG.PROCESS_CREDIT_STATMENT', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000871, 'CRD_PRC_MIGRATION_PKG.LOAD_INVOICE', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000872, 'CRD_PRC_MIGRATION_PKG.LOAD_DEBT', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000873, 'CRD_PRC_MIGRATION_PKG.LOAD_PAYMENT', 0, 9999, 0, 0)
/
delete from prc_process where id = 10000876
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000876, 'CRD_PRC_EXPORT_PKG.PROCESS_ACCOUNT', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000890, 'CRD_PRC_RESERVE_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
update prc_process set procedure_name = 'CRD_API_REPORT_PKG.PROCESS_CREDIT_STATEMENT' where id = 10000866
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001074, 'CRD_PRC_BILLING_PKG.PROCESS_INTEREST_POSTING', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001081, 'CRD_API_BILLING_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001144, 'CRD_PRC_EXPORT_PKG.EXPORT_CLOSED_CARDS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001149, 'CRD_PRC_EXPORT_PKG.EXPORT_CARDS_WITH_OVERDUE', 0, 9999, 0, 0, 0)
/
