insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status) values (3, 1, 'EVNT0162', 'ENSISSTM', 'CSTE0200', 'CSTE0300')
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status) values (4, 1, 'EVNT0162', 'ENSISSTM', 'CSTS0000', 'CSTS0003')
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status) values (5, 1, 'EVNT1906', 'ENSISSTM', 'CSTE0100', 'CSTE0400')
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1001, 1, 'EVNT0103', 'ENSISSTM', 'CSTE0200', 'CSTE0300', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1002, 1, 'EVNT0103', 'ENSISSTM', 'CSTS0000', 'CSTS0022', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1003, 1, 'EVNT0192', 'ENSICLNT', 'CSTS0000', 'CSTS0006', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1004, 1, 'EVNT0192', 'ENSICLNT', 'CSTE0200', 'CSTE0300', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1005, 1, 'EVNT0193', 'ENSICLNT', 'CSTS0000', 'CSTS0007', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1006, 1, 'EVNT0193', 'ENSICLNT', 'CSTE0200', 'CSTE0300', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1007, 1, 'EVNT0162', 'ENSICLNT', 'CSTS0000', 'CSTS0021', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1008, 1, 'EVNT0162', 'ENSICLNT', 'CSTE0200', 'CSTE0300', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1009, 1, 'EVNT0167', 'ENSIOPER', 'CSTS0000', 'CSTS0025', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1010, 1, 'EVNT0167', 'ENSIOPER', 'CSTE0200', 'CSTE0300', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1011, 1, 'EVNT0161', 'ENSICLNT', 'TSTS0001', 'TSTS0002', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1012, 1, 'EVNT0162', 'ENSICLNT', 'TSTS0001', 'TSTS0002', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1013, 1, 'EVNT0192', 'ENSICLNT', 'TSTS0001', 'TSTS0002', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1014, 1, 'EVNT0193', 'ENSICLNT', 'TSTS0001', 'TSTS0002', NULL, 9999)
/
delete from evt_status_map where event_type = 'EVNT0141' and initiator = 'ENSISSTM' and initial_status = 'CSTE0100' and inst_id = 9999
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1016, 1, 'EVNT0141', 'ENSISSTM', 'CSTE0100', 'CSTE0200', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1017, 1, 'EVNT0160', 'ENSISSTM', 'CSTS0030', 'CSTS0000', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1018, 1, 'EVNT0310', 'ENSISSTM', 'ACSTACRQ', 'ACSTACTV', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1019, 1, 'EVNT0005', 'ENSISSTM', 'CTST0030', 'CTST0010', NULL, 9999)
/
