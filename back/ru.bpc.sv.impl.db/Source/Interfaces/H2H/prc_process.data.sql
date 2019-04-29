insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001117, 'H2H_PRC_INCOMING_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001118, 'H2H_PRC_OUTGOING_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10001118
/
