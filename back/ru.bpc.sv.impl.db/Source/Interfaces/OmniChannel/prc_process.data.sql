insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001101, 'OMN_PRC_EXPORT_PKG.EXPORT_CUSTOMERS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001102, 'OMN_PRC_EXPORT_PKG.EXPORT_MERCHANTS', 0, 9999, 0, 0, 0)
/
update prc_process set procedure_name = 'ITF_OMN_PRC_CUST_EXPORT_PKG.PROCESS_CUSTOMER' where id = 10001101
/
update prc_process set procedure_name = 'ITF_OMN_PRC_MERCHANT_EXP_PKG.PROCESS_MERCHANT' where id = 10001102
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001104, 'ITF_OMN_PRC_CARD_EXPORT_PKG.EXPORT_CARDS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001124, 'ITF_OMN_PRC_PRODUCT_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
