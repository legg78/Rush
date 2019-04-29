insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000027, 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_STATUS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000029, 'ISS_PRC_IMPORT_PKG.IMPORT_CARDS_STATUS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000874, 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000877, 'ISS_PRC_IMPORT_PKG.IMPORT_CARD_BLACK_LIST', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000878, 'ISS_PRC_IMPORT_PKG.IMPORT_CARDS_SECURITY_DATA', 0, 9999, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10000874
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000952, 'ISS_PRC_REJECT_FILE_PKG.PROCESS_REJECTED_CARDS', 0, 9999, 0, 0, 0)
/
update prc_process set procedure_name='ITF_PRC_REJECT_FILE_PKG.PROCESS_REJECTED_CARDS' where id=10000952
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001028, 'ISS_PRC_CARD_INSTANCE_PKG.PROCESS_EXPIRE_DATE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001041, 'ISS_PRC_IMPORT_PKG.IMPORT_CARDS_STATUS', 1, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001042, 'ISS_PRC_IMPORT_PKG.IMPORT_CARDS_STATUS', 1, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001106, 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS', 0, 9999, 0, 0, 0)
/
update prc_process set procedure_name = 'ITF_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_NUMBERS' where id = 10000874
/
update prc_process set is_parallel = 1 where id = 10001106
/
update prc_process set procedure_name = 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS' where id = 10000874
/
delete from prc_process where id = 10001106
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001130, 'ITF_PRC_REJECT_FILE_PKG.PROCESS_REJECTED_PERSONS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001131, 'ISS_PRC_EXPORT_PKG.EXPORT_PERSONS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001132, 'ISS_PRC_EXPORT_PKG.EXPORT_COMPANIES', 0, 9999, 0, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10001028
/
