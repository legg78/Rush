insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000990, 'MUP_PRC_OUTGOING_PKG.UPLOAD', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000991, 'MUP_PRC_INCOMING_PKG.LOAD', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000992, 'MUP_PRC_BIN_PKG.LOAD_BIN', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000993, 'MUP_PRC_STTT_PKG.PROCESS_SUMMARY', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10000994, 'MUP_PRC_STTT_PKG.PROCESS_SETTLEMENT', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001068, 'MUP_PRC_DICTIONARY_PKG.LOAD_CURRENCY_RATE', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001107, 'MUP_PRC_SMS_INCOMING_PKG.PROCESS', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001115, 'MUP_PRC_REPORT_PKG.PROCESS_FORM_ACQ_OPER', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001116, 'MUP_PRC_REPORT_PKG.PROCESS_FORM_ISS_OPER', 0, 9999, 0, 0, 0)
/
delete prc_process where id = 10001107
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001121, 'MUP_PRC_INCOMING_PKG.LOAD_PARTICIPANT_TRANS_REPORT', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001141, 'MUP_PRC_REPORT_PKG.PROCESS_FORM_1_ISS_OPER', 0, 9999, 0, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container, interrupt_threads) values (10001142, 'MUP_PRC_REPORT_PKG.PROCESS_FORM_2_2_ACQ_OPER', 0, 9999, 0, 0, 0)
/
delete prc_process where id = 10001115
/
delete prc_process where id = 10001116
/
