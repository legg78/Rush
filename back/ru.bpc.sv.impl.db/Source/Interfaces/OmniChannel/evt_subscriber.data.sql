insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1265, 1, 'OMN_PRC_EXPORT_PKG.EXPORT_CUSTOMERS', 'EVNT0004', 40)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1266, 1, 'OMN_PRC_EXPORT_PKG.EXPORT_CUSTOMERS', 'EVNT0005', 50)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1267, 1, 'OMN_PRC_EXPORT_PKG.EXPORT_MERCHANTS', 'EVNT0200', 120)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1268, 1, 'OMN_PRC_EXPORT_PKG.EXPORT_MERCHANTS', 'EVNT0220', 140)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1269, 1, 'OMN_PRC_EXPORT_PKG.EXPORT_MERCHANTS', 'EVNT0230', 90)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1270, 1, 'OMN_PRC_EXPORT_PKG.EXPORT_MERCHANTS', 'EVNT0235', 110)
/
update evt_subscriber set procedure_name = 'ITF_OMN_PRC_CUST_EXPORT_PKG.PROCESS_CUSTOMER' where id = 1265
/
update evt_subscriber set procedure_name = 'ITF_OMN_PRC_CUST_EXPORT_PKG.PROCESS_CUSTOMER' where id = 1266
/
update evt_subscriber set procedure_name = 'ITF_OMN_PRC_MERCHANT_EXP_PKG.PROCESS_MERCHANT' where id = 1267
/
update evt_subscriber set procedure_name = 'ITF_OMN_PRC_MERCHANT_EXP_PKG.PROCESS_MERCHANT' where id = 1268
/
update evt_subscriber set procedure_name = 'ITF_OMN_PRC_MERCHANT_EXP_PKG.PROCESS_MERCHANT' where id = 1269
/
update evt_subscriber set procedure_name = 'ITF_OMN_PRC_MERCHANT_EXP_PKG.PROCESS_MERCHANT' where id = 1270
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1271, 1, 'ITF_OMN_PRC_CARD_EXPORT_PKG.EXPORT_CARDS', 'EVNT0982', 30)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1272, 1, 'ITF_OMN_PRC_CARD_EXPORT_PKG.EXPORT_CARDS', 'EVNT0100', 60)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1275, 1, 'ITF_OMN_PRC_CARD_EXPORT_PKG.EXPORT_CARDS', 'EVNT0132', 40)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1276, 1, 'ITF_OMN_PRC_CARD_EXPORT_PKG.EXPORT_CARDS', 'EVNT0133', 50)
/
