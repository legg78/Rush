insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000988, 'DPP_PRC_INSTALMENT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10000988
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001129, 'DPP_PRC_PAYMENT_PLAN_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
