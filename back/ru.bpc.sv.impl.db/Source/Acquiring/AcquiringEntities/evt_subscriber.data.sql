insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1016, 1, 'OPR_PRC_EXPORT_PKG.UPLOAD_OPERATION', 'EVNT0280', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1034, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF', 'EVNT0380', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1035, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF', 'EVNT0200', 20)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1036, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF', 'EVNT0220', 30)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1037, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF', 'EVNT0230', 40)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1038, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF', 'EVNT0235', 50)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1039, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF', 'EVNT0980', 60)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1111, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0245', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1170, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF', 'EVNT0981', 61)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1177, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF', 'EVNT0381', 11)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1185, 1, 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF', 'EVNT0231', 51)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1187, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0241', 11)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1205, 1, 'EVT_PRC_NOTIFICATION_PKG.GEN_ACQ_MIN_AMOUNT_NOTIFS', 'EVNT2009', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1243, 1, 'NTF_PRC_NOTIFICATION_PKG.MAKE_NOTIFICATION', 'EVNT2009', 15)
/
delete from evt_subscriber where id = 1205
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1249, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0980', 160)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1250, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0980', 170)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1251, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT', 'EVNT0981', 161)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1252, 1, 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL', 'EVNT0981', 171)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1332, 1, 'PMO_PRC_SCHEDULE_PKG.PROCESS', 'CYTP0214', 20)
/
