insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000011, 'MCW_PRC_IPM_PKG.LOAD', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000012, 'MCW_PRC_IPM_PKG.UPLOAD', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000013, 'MCW_PRC_MPE_PKG.LOAD', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000014, 'MCW_PRC_STTT_PKG.PROCESS_SUMMARY', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000015, 'MCW_PRC_STTT_PKG.PROCESS_SETTLEMENT', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000851, 'MCW_PRC_QPR_PKG.DATA_FOR_MASTER', 0, 9999, 0, 0)
/

update prc_process set procedure_name= 'MCW_PRC_QPR_PKG.QPR_MASTERCARD_DATA' where id = 10000851
/

insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000859, 'MCW_PRC_FRAUD_PKG.UPLOAD_FRAUD', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000885, 'MCW_PRC_MPE_PKG.LOAD_CURRENCY', 0, 9999, 0, 0, 0)
/

insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000889, 'QPR_PRC_AGGREGATE_PKG.REFRESH_AGGREGATE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000953, 'MCW_PRC_250BYTE_PKG.LOAD', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001020, 'MCW_PRC_MIGS_PKG.LOAD', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001029, 'MCW_PRC_ABU_PKG.EXPORT_FORMAT_R274', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001032, 'MCW_PRC_MDES_PKG.UPLOAD_BULK_R311', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001138, 'MCW_PRC_LTY_PKG.EXPORT', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001147, 'MCW_PRC_ABU_PKG.IMPORT_FORMAT_T275', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001151, 'MCW_PRC_ABU_PKG.EXPORT_FORMAT_R625', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001152, 'MCW_PRC_ABU_PKG.IMPORT_FORMAT_T626', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001158, 'MCW_PRC_MCOM_PKG.LOAD', 0, 9999, 0, 0, 0)
/
update prc_process set procedure_name = 'ru.bpc.sv2.scheduler.process.svng.mastercard.MasterComLoadDisputesProcess', is_parallel = 1, is_external = 1 where id = 10001158
/
