insert into evt_event (id, seqnum, event_type, scale_id, is_cached, inst_id) values (5001, 1, 'EVNT5001', NULL, 0, 9999)
/
insert into evt_event (id, seqnum, event_type, scale_id, is_cached, inst_id) values (-5006, 1, 'CYTP0407', NULL, 0, 9999)
/
update evt_event set event_type = 'CYTP1010' where id = -5006
/

