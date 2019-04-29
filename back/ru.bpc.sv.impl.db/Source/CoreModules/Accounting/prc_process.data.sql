insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000002, 'acc_api_entry_pkg.process_pending_entries', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000003, 'acc_api_entry_pkg.process_buffered_entries', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000008, 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 1, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000847, 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER_INFO', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000025, 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TRANSACTIONS', 0, 9999, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10000002
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000888, 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_TURNOVER_INFO', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000940, 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001109, 'ACC_PRC_MEMBER_EXPORT.UNLOAD_MEMBER_TURNOVER', 0, 9999, 0, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10001109
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001127, 'ACC_PRC_ACCOUNT_IMPORT_PKG.IMPORT_SETTL_ACKNOWLEDGEMENT', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001128, 'ITF_MPT_PRC_ACK_EXPORT_PKG.EXPORT_SETTL_ACKNOWLEDGEMENT', 0, 9999, 0, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10000847
/
update prc_process set is_parallel = 0 where id = 10000847
/
update prc_process set is_parallel = 1 where id = 10000888
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001139, 'ACC_PRC_ENTRY_BUFFER_PKG.DEFRAGMENT_ACC_ENTRY_BUFFER', 0, 9999, 0, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10000003
/
