insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000831, 'PRD_PRC_SERVICE_PKG.SWITCH_SERVICE_STATUS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000845, 'PRD_PRC_CUSTOMER_EXPORT_PKG.PROCESS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000875, 'PRD_PRC_PRODUCT_PKG.IMPORT_PRODUCTS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000943, 'PRD_PRC_PRODUCT_PKG.EXPORT_PRODUCTS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000944, NULL, 0, 9999, 0, 1, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001136, 'PRD_PRC_REFERRAL_PKG.CALCULATE_REWARDS', 0, 1001, 0, 0, 0)
/
update prc_process set inst_id = 9999 where id = 10001136
/
