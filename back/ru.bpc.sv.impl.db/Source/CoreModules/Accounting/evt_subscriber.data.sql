insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1015, 1, 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TRANSACTIONS', 'EVNT0360', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1021, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_CRDACC', 'EVNT0380', 20)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1087, 1, 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER_INFO', 'EVNT0361', 1)
/
update evt_subscriber set procedure_name = 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_TURNOVER_INFO' where id = 1087
/
update evt_subscriber set event_type = 'EVNT0361' where id = 1015
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1088, 1, 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 'EVNT0360', 20)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1112, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 'EVNT0380', 40)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1113, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0380', 50)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1114, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0380', 50)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1179, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_CRDACC', 'EVNT0381', 21)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1181, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 'EVNT0381', 41)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1182, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0381', 51)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1183, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0381', 51)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1287, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS', 'EVNT0380', 30)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1289, 1, 'ITF_MPT_PRC_ACK_EXPORT_PKG.EXPORT_SETTL_ACKNOWLEDGEMENT', 'EVNT0362', 10)
/
