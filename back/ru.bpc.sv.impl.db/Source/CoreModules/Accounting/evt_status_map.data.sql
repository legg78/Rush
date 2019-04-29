insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status) values (1, 1, 'EVNT0341', 'ENSISSTM', 'BLSTACTV', 'BLSTCLSD')
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status) values (2, 1, 'EVNT0341', 'ENSISSTM', 'BLSTINCT', 'BLSTACTV')
/
update evt_status_map set event_type = 'EVNT0342' where id = 1
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1015, 1, 'EVNT2106', 'ENSISSTM', 'ACSTACTV', 'ACSTDEBS', NULL, 9999)
/
update evt_status_map set event_type = 'EVNT1033' where id = 1015
/
