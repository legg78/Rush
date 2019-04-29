insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1014, 1, 'PMO_PRC_SCHEDULE_PKG.PROCESS', 'CYTP1401', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1241, 1, 'PMO_PRC_EXPORT_PKG.PROCESS', 'CYTP0407', 10)
/
update evt_subscriber set event_type = 'CYTP1010' where id = 1241
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1255, 1, 'PMO_PRC_EXPORT_PKG.PROCESS', 'CYTP1405', 20)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1256, 1, 'PMO_PRC_EXPORT_PKG.PROCESS', 'CYTP1406', 30)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1257, 1, 'PMO_PRC_EXPORT_PKG.PROCESS', 'CYTP1407', 40)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1258, 1, 'PMO_PRC_RETRY_PKG.PROCESS', 'CYTP1408', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1259, 1, 'PMO_PRC_RETRY_PKG.PROCESS', 'CYTP1409', 20)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1260, 1, 'PMO_PRC_RETRY_PKG.PROCESS', 'CYTP1410', 30)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1262, 1, 'PMO_PRC_SCHEDULE_PKG.PROCESS', 'CYTP1405', 12)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1263, 1, 'PMO_PRC_SCHEDULE_PKG.PROCESS', 'CYTP1406', 15)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1264, 1, 'PMO_PRC_SCHEDULE_PKG.PROCESS', 'CYTP1407', 16)
/

