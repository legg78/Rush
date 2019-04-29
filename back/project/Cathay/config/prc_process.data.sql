insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000315, 'CST_CAB_ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS', 1, 1001, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000317, 'CST_CAB_API_STATEMENT_PKG.EXPORT_CREDIT_STATEMENTS', 0, 1001, 0, 0, 0)
/
update prc_process set is_parallel = 1 where id = -50000317
/
