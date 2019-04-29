insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000918, 'QPR_PRC_AGGREGATE_PKG.AGGREGATE_OPERATIONS', 0, 9999, 0, 0, 0)
/
update prc_process set procedure_name = 'QPR_PRC_AGGREGATE_PKG.AGGREGATE_CARDS' where id = 10000918
/
update prc_process set procedure_name = 'QPR_PRC_AGGREGATE_PKG.REFRESH_AGGREGATE_CARDS' where id = 10000918
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000995, 'QPR_PRC_OUTGOING_PKG.AGGREGATE_MC_ISS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000996, 'QPR_PRC_OUTGOING_PKG.AGGREGATE_MC_ACQ', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000997, 'QPR_PRC_OUTGOING_PKG.AGGREGATE_VISA_ISS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000998, 'QPR_PRC_OUTGOING_PKG.AGGREGATE_VISA_ACQ', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000999, 'QPR_PRC_OUTGOING_PKG.PROCESS_MC_ACQ', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001000, 'QPR_PRC_OUTGOING_PKG.PROCESS_MC_ISS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001001, 'QPR_PRC_OUTGOING_PKG.PROCESS_VISA_ACQ', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001002, 'QPR_PRC_OUTGOING_PKG.PROCESS_VISA_ISS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001076, 'QPR_PRC_AGGREGATE_PKG.REFRESH_DETAIL', 0, 9999, 0, 0, 0)
/
