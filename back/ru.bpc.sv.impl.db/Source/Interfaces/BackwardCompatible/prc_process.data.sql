insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000030, 'ITF_PRC_ENTRY_PKG.UPLOAD_ENTRY_OBI', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000031, 'ITF_PRC_INCOMING_PKG.LOAD_OPERATION_ACCOUNT', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000032, 'ITF_PRC_OUTGOING_PKG.EXPORT_CARDS_STATUS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000037, 'ITF_PRC_RATE_PKG.LOAD_RATES_TLV', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000886, 'ITF_PRC_CARDGEN_PKG.GENERATE_WITHOUT_BATCH', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000887, 'ITF_PRC_CARDGEN_PKG.LOAD_CARDGEN_FILE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000891, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000892, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000899, 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 1, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000903, 'ITF_PRC_EVENT_PKG.PROCESS_EVENT_OBJECT', 0, 9999, 0, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10000891
/
update prc_process set is_parallel = 1 where id = 10000892
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000947, NULL, 0, 9999, 0, 1, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000951, 'ITF_PRC_REJECT_FILE_PKG.PROCESS_REJECTED_TURNOVER', 0, 9999, 0, 0, 0)
/
delete prc_process where id = 10001010
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001010, 'ITF_PRC_FRAUD_MONITORING_PKG.UNLOADING_CARDS_DATA', 0, 9999, 0, 0, 0)
/
delete prc_process where id = 10001011
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001011, 'ITF_PRC_FRAUD_MONITORING_PKG.UNLOADING_MERCHANT_DATA', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001012, 'ITF_PRC_FRAUD_MONITORING_PKG.UNLOADING_TERMINAL_DATA', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001013, 'ITF_PRC_FRAUD_MONITORING_PKG.UNLOADING_CLEARING_DATA', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001014, 'ITF_PRC_FRAUD_MONITORING_PKG.UNLOADING_CURRENCY_RATE_DATA', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001021, 'ITF_PRC_REJECT_FILE_PKG.PROCESS_REJECTED_MERCHANTS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001022, 'ITF_PRC_REJECT_FILE_PKG.PROCESS_REJECTED_TERMINALS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001075, 'ITF_PRC_INCOMING_PKG.PROCESS_ACCOUNT_EVENT', 0, 9999, 0, 0, 0)
/
update prc_process set procedure_name = 'ITF_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_NUMBERS' where id = 10000874
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001126, 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS', 1, 9999, 0, 0, 0)
/
update prc_process set procedure_name = 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS' where id = 10000874
/
