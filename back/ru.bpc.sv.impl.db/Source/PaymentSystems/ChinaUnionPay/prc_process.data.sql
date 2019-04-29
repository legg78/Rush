insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000935, 'ru.bpc.sv2.scheduler.process.cup.CupDisputeLoadProcess', 0, 9999, 1, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000936, 'ru.bpc.sv2.scheduler.process.cup.CupLoadProcess', 0, 9999, 1, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000937, 'ru.bpc.sv2.scheduler.process.cup.CupUnloadProcess', 0, 9999, 1, 0, 0)
/
update prc_process set is_external = 0, procedure_name = 'cup_prc_incoming_pkg.process' where id = 10000936
/
update prc_process set is_external = 0, procedure_name = 'cup_prc_outgoing_pkg.unload_clearing' where id = 10000937
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000986, 'cup_prc_dictionary_pkg.load_bin', 0, 9999, 0, 0, 0)
/
update prc_process set is_external = 0, procedure_name = 'cup_prc_incoming_pkg.load_clearing' where id = 10000936
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001023, 'cup_prc_incoming_pkg.load_interchange_fee', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001024, 'CUP_PRC_INCOMING_PKG.LOAD_DISPUTE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001025, 'CUP_PRC_INCOMING_PKG.PROCESS_AUDIT_TRAILER', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001026, 'CUP_PRC_INCOMING_PKG.LOAD_FEE_COLLECTION', 0, 9999, 0, 0, 0)
/
update prc_process set procedure_name = 'CUP_PRC_INCOMING_PKG.LOAD_AUDIT_TRAILER' where id = 10001025
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001027, 'CUP_PRC_MATCH_PKG.PROCESS_MATCH', 0, 9999, 0, 0, 0)
/
