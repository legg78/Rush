insert into evt_event (id, seqnum, event_type, scale_id, is_cached, inst_id) values (1091, 1, 'EVNT2303', NULL, 0, 9999)
/
insert into evt_event (id, seqnum, event_type, scale_id, is_cached, inst_id) values (1094, 1, 'CYTP1014', NULL, 0, 9999)
/
insert into evt_event (id, seqnum, event_type, scale_id, is_cached, inst_id) values (1093, 1, 'CYTP0417', NULL, 0, 9999)
/
update evt_event set event_type = 'CYTP1417' where id = 1093
/
update evt_event set event_type = 'CYTP1017' where id = 1093
/
