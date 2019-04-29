insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001004, 'WAY_PRC_INCOMING_PKG.PROCESS_WAY4_XML', 0, 9999, 1, 0, 1)
/
update prc_process set is_external = 0 where id = 10001004
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001099, 'WAY_PRC_OUTGOING_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
