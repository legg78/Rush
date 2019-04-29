insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000189, 'CST_IBB_PRC_STATEMENT_PKG.CREATE_PREPAID_CARD_STATEMENTS', 0, 9999, 0, 0, 0)
/
update prc_process set procedure_name = 'CST_IBBL_PRC_STATEMENT_PKG.CREATE_PREPAID_CARD_STATEMENTS' where id = -50000189
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000190, 'CST_IBBL_PRC_CHECKBOOK_PKG.PROCESS_CHECKBOOK_ISSUANCE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000230, 'CST_IBBL_PRC_MERCHANT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000229, 'CST_IBBL_PRC_OUTGOING_PKG.CREATE_OPERATIONS_FROM_VSS_MSG', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (-50000228, 'CST_IBBL_PRC_OUTGOING_PKG.DEBIT_CARDS_TURNOVERS', 0, 9999, 0, 0, 0)
/
