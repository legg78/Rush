insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000840, 'INS_PRC_PREMIUM_PKG.PROCESS', 0, 9999, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10000840
/
