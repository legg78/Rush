insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1105, 1, 'COM_PRC_RATE.UNLOAD_RATES', 'EVNT1910', 10)
/
update evt_subscriber set procedure_name = 'COM_PRC_RATE_PKG.UNLOAD_RATES' where id = 1105
/