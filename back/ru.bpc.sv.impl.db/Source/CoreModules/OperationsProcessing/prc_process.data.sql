insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000303, 'opr_api_process_pkg.process_operations', 1, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000006, 'OPR_PRC_MATCH_PKG.PROCESS_MATCH', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000007, 'OPR_PRC_MATCH_PKG.PROCESS_MARK_EXPIRED', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000026, 'OPR_PRC_IMPORT_PKG.LOAD_OPERATIONS', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000047, 'OPR_PRC_EXPORT_PKG.UPLOAD_OPERATION', 0, 9999, 0, 0)
/
update prc_process set is_parallel = 1 where id = 10000006
/
update prc_process set is_parallel = 1 where id = 10000026
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000896, 'OPR_PRC_IMPORT_PKG.LOAD_STTT', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000897, 'OPR_PRC_IMPORT_PKG.LOAD_UPDATE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000933, 'OPR_PRC_IMPORT_PKG.LOAD_OPERATIONS_EXTEND', 1, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001005, 'RU.BPC.SV2.SCHEDULER.PROCESS.SVNG.LOADPOSTINGPROCESS', 1, 9999, 1, 0, 0)
/
update prc_process set procedure_name = 'ru.bpc.sv2.scheduler.process.svng.LoadPostingProcess' where id=10001005
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001008, 'OPR_PRC_IMPORT_PKG.LOAD_FRAUD_CONTROL', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001038, 'ru.bpc.sv2.scheduler.process.svng.LoadPostingProcess', 0, 9999, 1, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001087, 'ru.bpc.sv2.scheduler.process.svng.LoadPostingProcess', 1, 9999, 1, 0, 0)
/
update prc_process set procedure_name = 'ITF_PRC_IMPORT_PKG.LOAD_OPERATIONS_EXTEND' where id = 10000933
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001145, 'OPR_PRC_MATCH_PKG.INSERT_MATCH_DATA', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001146, NULL, 0, 9999, 0, 1, 0)
/
update prc_process set procedure_name = 'OPR_PRC_MATCH_PKG.PROCESS_MATCH_OBSOLETE' where id = 10000006
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001150, 'OPR_PRC_MATCH_PKG.PROCESS_MATCH', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001154, 'CST_GPB_PMO_PRC_MAKE_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
