insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1089, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0220', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1090, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0200', 30)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1091, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0230', 20)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1092, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0235', 40)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1094, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0240', 20)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1095, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0210', 30)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1102, 1, 'ITF_PRC_EVENT_PKG.PROCESS_EVENT_OBJECT', 'EVNT1005', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1103, 1, 'ITF_PRC_EVENT_PKG.PROCESS_EVENT_OBJECT', 'EVNT1018', 20)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1104, 1, 'ITF_PRC_EVENT_PKG.PROCESS_EVENT_OBJECT', 'EVNT1021', 30)
/
update evt_subscriber set event_type = 'EVNT1011' where id = 1102
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1106, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 'EVNT0360', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1107, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 'EVNT0320', 20)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1108, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 'EVNT0390', 30)
/
delete from evt_subscriber where id = 1107
/
delete from evt_subscriber where id = 1108
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1110, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 'EVNT0300', 60)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1109, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 'EVNT0301', 50)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1117, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 'EVNT0310', 30)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1119, 1, 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS', 'EVNT0143', 80)
/
update evt_subscriber set procedure_name = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER' where id = 1132
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1134, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER', 'EVNT1710', 70)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1153, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0320', 60)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1154, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0320', 40)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1155, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0390', 70)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1156, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0390', 60)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1157, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0215', 70)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1166, 1, 'ITF_PRC_FRAUD_MONITORING_PKG.UNLOADING_CARDS_DATA', 'EVNT1918', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1184, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0231', 41)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1283, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS', 'EVNT0300', 70)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1284, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS', 'EVNT0301', 60)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1285, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS', 'EVNT0310', 50)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1286, 1, 'ITF_PRC_ACCOUNT_EXPORT_PKG.UNLOAD_MERCHANT_ACCOUNTS', 'EVNT0360', 40)
/
