insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000826, 'ACQ_PRC_REIMB_BATCH_PKG.PROCESS', 1, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000827, 'ACQ_PRC_REIMB_UPLOAD_PKG.PROCESS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000028, 'ACQ_PRC_IMPORT_PKG.IMPORT_FEES', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001035, 'EVT_PRC_NOTIFICATION_PKG.GEN_ACQ_MIN_AMOUNT_NOTIFS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001051, 'ACQ_PRC_MERCHANT_PKG.CALCULATE_MERCHANTS_STATISTIC', 0, 9999, 0, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10001051
/
