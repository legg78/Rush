insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000841, 'VIS_PRC_OUTGOING_PKG.PROCESS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000842, 'VIS_PRC_INCOMING_PKG.PROCESS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000017, 'VIS_PRC_DICTIONARY_PKG.LOAD_ARDEF', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000018, 'VIS_PRC_DICTIONARY_PKG.LOAD_COUNTRY', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000019, 'VIS_PRC_DICTIONARY_PKG.LOAD_MCC', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000020, 'VIS_PRC_DICTIONARY_PKG.LOAD_CURRENCY', 0, 9999, 0, 0)
/

insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000852, 'VIC_PRC_QPR_PKG.QPR_VISA_DATA', 0, 9999, 0, 0)
/

update prc_process set procedure_name = 'VIS_PRC_QPR_PKG.QPR_VISA_DATA' where id = 10000852
/


insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000934, 'VIS_PRC_INCOMING_PKG.PROCESS_REJECTED_ITEM_FILE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001033, 'VIS_PRC_VDEP_PKG.UPLOAD_BULK', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001060, 'VIS_PRC_OUTGOING_PKG.PROCESS_UNLOAD_SMS_DISPUTE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001090, 'VIS_PRC_INCOMING_PKG.VSS_REPORT_UPLOADING', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001153, 'VIS_PRC_AMMF_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001155, 'VIS_PRC_VCF_PKG.EXPORT_DATA', 0, 9999, 0, 0, 0)
/
