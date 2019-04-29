insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1242, 1, 'VIS_PRC_OUTGOING_PKG.PROCESS_UNLOAD_SMS_DISPUTE', 'EVNT2010', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1330, 1, 'VIS_PRC_AMMF_PKG.PROCESS', 'EVNT0230', 110)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1331, 1, 'VIS_PRC_AMMF_PKG.PROCESS', 'EVNT0280', 20)
/
update evt_subscriber set event_type = 'EVNT0281' where id = 1331
/
