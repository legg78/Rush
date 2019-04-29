insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000304, 'FCL_PRC_CYCLE_COUNTER_PKG.PROCESS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000806, 'FCL_PRC_FLUSH_LIMIT_PKG.PROCESS', 0, 9999, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10000304
/
