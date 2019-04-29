insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1020, 1, 'EVNT0501', 'ENSISSTM', 'CTST0020', 'CTST0010', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1021, 1, 'EVNT0502', 'ENSISSTM', 'CTST0010', 'CTST0020', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1022, 1, 'EVNT0501', 'ENSISSTM', 'CSTS0030', 'CTST0010', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1023, 1, 'EVNT0504', 'ENSISSTM', 'MRCS0003', 'MRCS0001', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1024, 1, 'EVNT0504', 'ENSISSTM', 'MRCS0009', 'MRCS0001', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1025, 1, 'EVNT0505', 'ENSISSTM', 'MRCS0001', 'MRCS0009', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1026, 1, 'EVNT0506', 'ENSISSTM', 'MRCS0001', 'MRCS0003', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1027, 1, 'EVNT0507', 'ENSISSTM', 'TSTS0002', 'TSTS0001', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1028, 1, 'EVNT0508', 'ENSISSTM', 'TSTS0001', 'TSTS0002', NULL, 9999)
/
insert into evt_status_map (id, seqnum, event_type, initiator, initial_status, result_status, priority, inst_id) values (1029, 1, 'EVNT0509', 'ENSISSTM', 'TSTS0001', 'TSTS0003', NULL, 9999)
/
delete from evt_status_map where id = 1020
/
update evt_status_map set initial_status = 'TRMS0002', result_status = 'TRMS0001' where id = 1027
/
update evt_status_map set initial_status = 'TRMS0001', result_status = 'TRMS0002' where id = 1028
/
update evt_status_map set initial_status = 'TRMS0001', result_status = 'TRMS0003' where id = 1029
/
update evt_status_map set initial_status = 'TRMS0001', result_status = 'TRMS0009' where id = 1028
/
update evt_status_map set initial_status = 'TRMS0001', result_status = 'TRMS0002' where id = 1029
/
